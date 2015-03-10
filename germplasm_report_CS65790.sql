--SET CURRRENT SESSION GERMPLASM INFO
set global.germplasm_name= 'CS65790';


--validate current germplasm name has been set
SELECT current_setting('global.germplasm_name'); 

--GERMPLASM BASE INFO 
SELECT
	s.name germplasm_name, c.name germplasm_type,
	db.urlprefix || dbx.accession germplasm_tair_accession_url,
	dbx.accession germplasm_tair_accession,
	s.description, o.genus || ' ' || o.species taxon, n.object_stock_name || ' ' || object_stock_uniquename accession
FROM
	stock s
		JOIN dbxref dbx
		ON
		s.dbxref_id = dbx.dbxref_id JOIN db
		ON
		db.db_id = dbx.db_id 
		join organism o
		on
		o.organism_id = s.organism_id
		join 
		cvterm c 
		on c.cvterm_id = s.type_id
		left join
		(
		select sb.stock_id subject_stock_id, sb.name subject_name, so.stock_id object_stock_id, so.name object_stock_name, so.uniquename object_stock_uniquename  from stock_relationship sp
		join stock sb
		on sb.stock_id = sp.subject_id
		join stock so
		on so.stock_id = sp.object_id
		join cvterm cspo
		on cspo.cvterm_id = sp.type_id
		join
		cvterm cso
		on cso.cvterm_id = so.type_id
		where cspo.name = 'associated_with' and cso.name = 'ecotype'
			) n
			on n.subject_stock_id = s.stock_id
	WHERE
	s.name in (SELECT current_setting('global.germplasm_name'));
	
	
	-- Natural Accession Properties
	SELECT
    s.name germplasm_name, c.name germplasm_type,
   o.genus || ' ' || o.species taxon, n.object_stock_name || ' ' || object_stock_uniquename accession, n.property, n.value
FROM
    stock s
        JOIN dbxref dbx
        ON
        s.dbxref_id = dbx.dbxref_id JOIN db
        ON
        db.db_id = dbx.db_id 
        join organism o
        on
        o.organism_id = s.organism_id
        join 
        cvterm c 
        on c.cvterm_id = s.type_id
        left join
        (
        select sb.stock_id subject_stock_id, sb.name subject_name, so.stock_id object_stock_id, so.name object_stock_name, so.uniquename object_stock_uniquename, sprc.name property, spr.value  from stock_relationship sp
        join stock sb
        on sb.stock_id = sp.subject_id
        join stock so
        on so.stock_id = sp.object_id
        join cvterm cspo
        on cspo.cvterm_id = sp.type_id
        join
        cvterm cso
        on cso.cvterm_id = so.type_id
        left join
        stockprop spr
        on spr.stock_id = so.stock_id
        join cvterm sprc
        on sprc.cvterm_id = spr.type_id
        where cspo.name = 'associated_with' and cso.name = 'ecotype'
            ) n
            on n.subject_stock_id = s.stock_id
           
    WHERE
    s.name in (SELECT current_setting('global.germplasm_name'));
	
-- GERMPLASM TAIR ACCESSIONS

    SELECT
	s.name germplasm_name,
	db.name || ':' || dbx.accession as tair_accession,
	db.urlprefix || dbx.accession accession_url
FROM
	stock s JOIN dbxref dbx
		ON
		s.dbxref_id = dbx.dbxref_id JOIN db
		ON
		db.db_id = dbx.db_id
WHERE
	s.name in (SELECT current_setting('global.germplasm_name'))
UNION
SELECT
	s.name germplasm_name,
	db.name || ':' || dbx.accession as tair_accession,
	db.urlprefix || dbx.accession accession_url
FROM
	stock s
		LEFT JOIN
		stock_dbxref stb
		ON
		s.stock_id = stb.stock_id JOIN dbxref dbx
		ON
		dbx.dbxref_id = stb.dbxref_id JOIN db
		ON
		dbx.db_id = db.db_id
WHERE
	s.name in (SELECT current_setting('global.germplasm_name'))
	;

-- Other Names - NASC Stock Number
select s.name germplasm_name, sn.name nasc_stock_number from stock_synonym stn
join 
synonym sn
on stn.synonym_id = sn.synonym_id
join
stock s
on s.stock_id = stn.stock_id
and s.name in (SELECT current_setting('global.germplasm_name'));

-- GERMPPLASM DESCRIPTOR

--GERMPLASM ANNOTATED TERMS
SELECT
	s.name germplasm_name,
	s.description,
	cv.name term_type,
	case when sv.is_not then 'is not a' else 'is a' end as relationship_type,
	c.name assigned_term
FROM
	stock_cvterm sv JOIN cvterm c
		ON
		c.cvterm_id = sv.cvterm_id JOIN cv
		ON
		cv.cv_id = c.cv_id JOIN stock s
		ON
		s.stock_id = sv.stock_id
WHERE
	s.name in (SELECT current_setting('global.germplasm_name'))
ORDER BY
	sv.rank;
	
-- GERMPLASM MUTAGEN 
SELECT
	s.name germplasm_name,
	cv.name term_type,
	c.name mutagen
FROM
	stock_cvterm sv JOIN cvterm c
		ON
		c.cvterm_id = sv.cvterm_id JOIN cv
		ON
		cv.cv_id = c.cv_id JOIN stock s
		ON
		s.stock_id = sv.stock_id
WHERE
	s.name in (SELECT current_setting('global.germplasm_name')) and cv.name = 'mutagen_type'
ORDER BY
	sv.rank;

-- CHROMOSOMAL CONSTITUTION
SELECT
	s.name germplasm_name,
	cv.name term_type,
	case when sv.is_not then 'is not a' else 'is a' end as relationship_type,
	c.name aneploid,
	cp.name ploidy_property,
	sp.value ploidy_value
FROM
	stock_cvterm sv JOIN cvterm c
		ON
		c.cvterm_id = sv.cvterm_id JOIN cv
		ON
		cv.cv_id = c.cv_id JOIN stock s
		ON
		s.stock_id = sv.stock_id
		left
		join stockprop sp
		on s.stock_id = sp.stock_id
		left join cvterm cp
		on sp.type_id = cp.cvterm_id
		left join cv cvp
		on cvp.cv_id = cp.cv_id
		
WHERE
	s.name in (SELECT current_setting('global.germplasm_name')) and cv.name = 'chromosomal_constitution' and cp.name = 'ploidy' 
ORDER BY
	sv.rank;

-- OTHER GERMPLASM PROPERTIES

select s.name, c.name as property_type, sp.value from stock s
join stockprop sp
on s.stock_id = sp.stock_id
join cvterm c
on sp.type_id = c.cvterm_id
where s.name in (SELECT current_setting('global.germplasm_name'))
order by rank;

--PEDIGREE 
-- GEMPLASM BACKGROUND ACCESSION
SELECT sbc.name as type, sb.uniquename as background_accession, ' is a ' || c.name as relationship, so.name as germplasm_name, soc.name germplasm_type  from STOCK_RELATIONSHIP str
join stock so
on 
so.stock_id = str.object_id 
join 
cvterm c
on 
c.cvterm_id = str.type_id
join
stock sb
on sb.stock_id = str.subject_id
join 
cvterm sbc
on sbc.cvterm_id = sb.type_id
join 
cvterm soc
on soc.cvterm_id = so.type_id
where so.name in (SELECT current_setting('global.germplasm_name')) and c.name  like  '%background_accession%';

-- all parent lines and associated locus
SELECT str.stock_relationship_id, sbc.name as germplasm_type, sb.uniquename as germplasm_name, ' is a ' || c.name as relationship, so.name as parent_line, sbc.name parent_type,  v.locus  parent_locus_associations,cc.name generative_method from STOCK_RELATIONSHIP str
join stock so
on 
so.stock_id = str.object_id 
join 
cvterm c
on 
c.cvterm_id = str.type_id
join
stock sb
on sb.stock_id = str.subject_id
join 
cvterm sbc
on sbc.cvterm_id = sb.type_id
join 
cvterm soc
on soc.cvterm_id = so.type_id
left join
stock_relationship_cvterm strc
on str.stock_relationship_id = strc.stock_relationship_id
left join 
cvterm cc
on 
cc.cvterm_id = strc.cvterm_id
left join 
(
select distinct f."name" locus, fo."name" allele,  s.name germplasm_name, s.stock_id from feature_relationship fp 
join feature f
on f.feature_id = fp.object_id
join feature fo
on fo.feature_id = fp.subject_id
join feature_genotype fg
on fg.feature_id = fo.feature_id
join genotype g
on fg.genotype_id = g.genotype_id
join stock_genotype sg
on sg.genotype_id = g.genotype_id
join stock s
on s.stock_id = sg.stock_id
join cvterm fc
on fc.cvterm_id = f.type_id
where s.name in (SELECT current_setting('global.germplasm_name')) and fc.name = 'gene'
) V
ON
V.stock_id = sb.stock_id
where sb.name in (SELECT current_setting('global.germplasm_name')) and c.name = 'offspring_of' order by str.rank;

-- Locus and allele feature/allele mutagen accociated with the germplasm 
select distinct f."name" locus, fo."name" allele,  m.property, m.mutagen, s.name germplasm_name from feature_relationship fp 
join feature f
on f.feature_id = fp.object_id
join feature fo
on fo.feature_id = fp.subject_id
join feature_genotype fg
on fg.feature_id = fo.feature_id
join genotype g
on fg.genotype_id = g.genotype_id
join stock_genotype sg
on sg.genotype_id = g.genotype_id
join stock s
on s.stock_id = sg.stock_id
join cvterm fc
on fc.cvterm_id = f.type_id
join cvterm fco
on fco.cvterm_id = fo.type_id
left join
(
select f.feature_id, cf.name feature_type, f.uniquename, fcp."value" property, c."name" mutagen from feature_cvterm fc 
     join feature f
     on fc.feature_id = f.feature_id
     join 
     feature_cvtermprop fcp
     on fcp.feature_cvterm_id = fc.feature_cvterm_id
     join 
     cvterm cvtp
     on 
     cvtp.cvterm_id = fcp.type_id
     join cvterm c
     on c.cvterm_id = fc.cvterm_id
     join
     cvterm cf
     on cf.cvterm_id = f.type_id
     where
     fcp.VALUE = 'origin_of_mutation'
) m
on m.feature_id = fo.feature_id
where s.name in (SELECT current_setting('global.germplasm_name')) and fco.name = 'allele' and fc.name = 'gene';

--PHENOTYPE ASSOCIATED WITH GERMPLASM
select s.name germplasm_name, pt.value phenotype, pt.uniquename phenotype_accession, cp.name as attribute, ca.name evidence_type from stock_phenotype stp
join phenotype pt
on pt.phenotype_id = stp.phenotype_id
join stock s
on s.stock_id = stp.stock_id
join
cvterm ca
on ca.cvterm_id = pt.assay_id
join
cvterm cp
on cp.cvterm_id = pt.attr_id 
where s.name in (SELECT current_setting('global.germplasm_name'));

--PHENOTYPE PUBLICATIONS BY STOCK_NAME
 select ps.phenotype_id, pd.description, p.uniquename publication, p.pyear, p.title from phendesc pd
 join
 phenstatement ps
 on 
 pd.genotype_id = ps.genotype_id
 join
 stock_genotype sg
 on sg.genotype_id = pd.genotype_id
 join stock s
 on s.stock_id = sg.stock_id
 join
 pub p
 on p.pub_id = ps.pub_id
 where s.name in (SELECT current_setting('global.germplasm_name'));
 
 -- GERMPLASM PUBLICATION
 
select s.name germplasm_name, coalesce(p.uniquename, 'N/A') publication, coalesce(p.title, 'N/A') as title,  coalesce(p.pyear, 'N/A') as year from stock s
left join
stock_pub sp
on s.stock_id = sp.stock_id
left join pub p
on 
p.pub_id = sp.pub_id
where s.name in (SELECT current_setting('global.germplasm_name'));
 
-- Germplasmm Attribution
select s.name germplasm_name, c.name attribution_type, ct.name submitter_name, date_created date from stock_attribution st
join
stock s
on s.stock_id = st.stock_id
join contact ct
on ct.contact_id = st.contact_id
join cvterm c
on
c.cvterm_id = st.type_id
left join
pub p on 
p.pub_id= st.pub_id
where s.name in (SELECT current_setting('global.germplasm_name'));

 
-- GENETIC CONTEXT

-- Germplasm Polymorphisms
SELECT
	s.name germplasm_name, 
	g.name genotype_name,
	cvg.name genotype_type,
	g.uniquename genotype_uniquename,
	g.description genotype_description,
	c.name zygosity,
	db.urlprefix || dbx.accession tair_accession_url,
	dbx.accession tair_accession
FROM
	stock_genotype sg
	left join
	cvterm c 
	on c.cvterm_id = sg.cvterm_id
	join stock s
	on s.stock_id = sg.stock_id
	join genotype g
	on g.genotype_id = sg.genotype_id
	join
	cvterm cvg
	on cvg.cvterm_id = g.type_id
	join cv 
	on cv.cv_id = c.cv_id 
	join
	dbxref dbx
	on dbx.dbxref_id = g.dbxref_id
	join
	db on db.db_id = dbx.db_id
	where s.name in (SELECT current_setting('global.germplasm_name')) and cv.name = 'genotype_type';
	
--POLYMORHISM PROPERTIES
select g.name genotype_name, cgp.name property, gp.value property_value from genotype g
join stock_genotype sg
on sg.genotype_id = g.genotype_id
join stock s
on s.stock_id = sg.stock_id
join
genotypeprop gp
on 
gp.genotype_id = g.genotype_id
join 
cvterm cgp
on cgp.cvterm_id = gp.type_id
where s.name in (SELECT current_setting('global.germplasm_name'));
	
-- Polymorphism  TAIR Accessions

SELECT
	s.name germplasm_name, 
	g.name genotype_name,
	db.name || ':' || dbx.accession as tair_accession,
	db.urlprefix || dbx.accession tair_accession_url
FROM
	stock_genotype sg
	join stock s
	on s.stock_id = sg.stock_id
	join genotype g
	on g.genotype_id = sg.genotype_id
	join
	dbxref dbx
	on dbx.dbxref_id = g.dbxref_id
	join
	db on db.db_id = dbx.db_id
	where s.name in (SELECT current_setting('global.germplasm_name'))
	union
	SELECT
	s.name germplasm_name, 
	g.name genotype_name,
	db.name || ':' || dbx.accession as tair_accession,
	db.urlprefix || dbx.accession tair_accession_url
	FROM
	stock_genotype sg
	join stock s
	on s.stock_id = sg.stock_id
	join genotype g
	on g.genotype_id = sg.genotype_id
	left join
	genotype_dbxref gdb
	on 
	gdb.genotype_id = g.genotype_id
	join
	dbxref dbx
	on dbx.dbxref_id = gdb.dbxref_id
	join
	db on db.db_id = dbx.db_id
	where s.name in (SELECT current_setting('global.germplasm_name'));

-- POLYMORPHISM SYNONYMS
select g.name genotype_name, s.name synonym from genotype_synonym gs
join genotype g
on g.genotype_id = gs.genotype_id
join synonym s
on s.synonym_id = gs.synonym_id
join cvterm c
on c.cvterm_id = s.type_id
join stock_genotype sg
on sg.genotype_id = g.genotype_id
join stock st
on st.stock_id = sg.stock_id
where st.name in (SELECT current_setting('global.germplasm_name'));

-- Associated Clone Construct Type
select distinct fo."name" allele,  m.property, m.clone_construct_type, s.name germplasm_name from feature_relationship fp 
join feature f
on f.feature_id = fp.object_id
join feature fo
on fo.feature_id = fp.subject_id
join feature_genotype fg
on fg.feature_id = fo.feature_id
join genotype g
on fg.genotype_id = g.genotype_id
join stock_genotype sg
on sg.genotype_id = g.genotype_id
join stock s
on s.stock_id = sg.stock_id
join cvterm fc
on fc.cvterm_id = f.type_id
join cvterm fco
on fco.cvterm_id = fo.type_id
left join
(
select f.feature_id, cf.name feature_type, f.uniquename, fcp."value" property, c."name" clone_construct_type from feature_cvterm fc 
     join feature f
     on fc.feature_id = f.feature_id
     join 
     feature_cvtermprop fcp
     on fcp.feature_cvterm_id = fc.feature_cvterm_id
     join 
     cvterm cvtp
     on 
     cvtp.cvterm_id = fcp.type_id
     join cvterm c
     on c.cvterm_id = fc.cvterm_id
     join
     cvterm cf
     on cf.cvterm_id = f.type_id
     where
     fcp.VALUE = 'clone_construct_type'
) m
on m.feature_id = fo.feature_id
where s.name in (SELECT current_setting('global.germplasm_name')) and fco.name = 'allele' and fc.name = 'gene';


-- Locus and allele feature/allele mutagen accociated with the germplasm polymorhisms
select distinct f."name" locus, fo."name" allele,  m.property, m.mutagen, s.name germplasm_name from feature_relationship fp 
join feature f
on f.feature_id = fp.object_id
join feature fo
on fo.feature_id = fp.subject_id
join feature_genotype fg
on fg.feature_id = fo.feature_id
join genotype g
on fg.genotype_id = g.genotype_id
join stock_genotype sg
on sg.genotype_id = g.genotype_id
join stock s
on s.stock_id = sg.stock_id
join cvterm fc
on fc.cvterm_id = f.type_id
join cvterm fco
on fco.cvterm_id = fo.type_id
left join
(
select f.feature_id, cf.name feature_type, f.uniquename, fcp."value" property, c."name" mutagen from feature_cvterm fc 
     join feature f
     on fc.feature_id = f.feature_id
     join 
     feature_cvtermprop fcp
     on fcp.feature_cvterm_id = fc.feature_cvterm_id
     join 
     cvterm cvtp
     on 
     cvtp.cvterm_id = fcp.type_id
     join cvterm c
     on c.cvterm_id = fc.cvterm_id
     join
     cvterm cf
     on cf.cvterm_id = f.type_id
     where
     fcp.VALUE = 'origin_of_mutation'
) m
on m.feature_id = fo.feature_id
where s.name in (SELECT current_setting('global.germplasm_name')) and fco.name = 'allele' and fc.name = 'gene';
    
-- ALLELE MUTAGEN
select fo.name allele,  m.property, m.mutagen, s.name germplasm_name from feature_relationship fp 
join feature f
on f.feature_id = fp.object_id
join feature fo
on fo.feature_id = fp.subject_id
join feature_genotype fg
on fg.feature_id = fo.feature_id
join genotype g
on fg.genotype_id = g.genotype_id
join stock_genotype sg
on sg.genotype_id = g.genotype_id
join stock s
on s.stock_id = sg.stock_id
join cvterm fc
on fc.cvterm_id = f.type_id
join cvterm fco
on fco.cvterm_id = fo.type_id
left join
(
select f.feature_id, cf.name feature_type, f.uniquename, fcp."value" property, c."name" mutagen from feature_cvterm fc 
     join feature f
     on fc.feature_id = f.feature_id
     join 
     feature_cvtermprop fcp
     on fcp.feature_cvterm_id = fc.feature_cvterm_id
     join 
     cvterm cvtp
     on 
     cvtp.cvterm_id = fcp.type_id
     join cvterm c
     on c.cvterm_id = fc.cvterm_id
     join
     cvterm cf
     on cf.cvterm_id = f.type_id
     where
     fcp.VALUE = 'origin_of_mutation'
) m
on m.feature_id = fo.feature_id
where s.name in (SELECT current_setting('global.germplasm_name')) and fco.name = 'allele' and fc.name = 'gene';
     
-- Allele Mutation Site
select fo.name allele,  m.property, coalesce(m.value, 'N/A') mutation_site, s.name germplasm_name from feature_relationship fp 
join feature f
on f.feature_id = fp.object_id
join feature fo
on fo.feature_id = fp.subject_id
join feature_genotype fg
on fg.feature_id = fo.feature_id
join genotype g
on fg.genotype_id = g.genotype_id
join stock_genotype sg
on sg.genotype_id = g.genotype_id
join stock s
on s.stock_id = sg.stock_id
join cvterm fc
on fc.cvterm_id = f.type_id
join cvterm fco
on fco.cvterm_id = fo.type_id
left join
(
select f.feature_id, cf.name feature_type, f.uniquename, fcp.value property, c.name  as value from feature_cvterm fc 
     join feature f
     on fc.feature_id = f.feature_id
     join 
     feature_cvtermprop fcp
     on fcp.feature_cvterm_id = fc.feature_cvterm_id
     join 
     cvterm cvtp
     on 
     cvtp.cvterm_id = fcp.type_id
     join cvterm c
     on c.cvterm_id = fc.cvterm_id
     join
     cvterm cf
     on cf.cvterm_id = f.type_id
     where
     fcp.VALUE = 'mutation_site'
) m
on m.feature_id = fo.feature_id
where s.name in (SELECT current_setting('global.germplasm_name')) and fco.name = 'allele' and fc.name = 'gene';
     
 -- Allele Type
select fo.name allele,  m.property, coalesce(m.value, 'N/A') allele_type, s.name germplasm_name from feature_relationship fp 
join feature f
on f.feature_id = fp.object_id
join feature fo
on fo.feature_id = fp.subject_id
join feature_genotype fg
on fg.feature_id = fo.feature_id
join genotype g
on fg.genotype_id = g.genotype_id
join stock_genotype sg
on sg.genotype_id = g.genotype_id
join stock s
on s.stock_id = sg.stock_id
join cvterm fc
on fc.cvterm_id = f.type_id
join cvterm fco
on fco.cvterm_id = fo.type_id
left join
(
select f.feature_id, cf.name feature_type, f.uniquename, fcp.value property, c.name  as value from feature_cvterm fc 
     join feature f
     on fc.feature_id = f.feature_id
     join 
     feature_cvtermprop fcp
     on fcp.feature_cvterm_id = fc.feature_cvterm_id
     join 
     cvterm cvtp
     on 
     cvtp.cvterm_id = fcp.type_id
     join cvterm c
     on c.cvterm_id = fc.cvterm_id
     join
     cvterm cf
     on cf.cvterm_id = f.type_id
     where
     fcp.VALUE = 'allele_type'
) m
on m.feature_id = fo.feature_id
where s.name in (SELECT current_setting('global.germplasm_name')) and fco.name = 'allele' and fc.name = 'gene';
     
--GERMPLASM/POLYMORPHISM ASSOCIATED LOCUS AND GENES

select distinct s.name germplasm_name, g.name genotype_name, fgc.name relationship, f.name as allele_name, fpoc.name association_type, sg_cv.name zygocity, fpo.name locus, v.gene_name genes_names, v.gene_full_name from feature_genotype fg 
join 
stock_genotype sg
on sg.genotype_id = fg.genotype_id
left join
cvterm sg_cv
on sg_cv.cvterm_id = sg.cvterm_id
join stock s
on s.stock_id = sg.stock_id
join 
cvterm fgc
on fgc.cvterm_id = fg.cvterm_id 
join 
genotype g
on g.genotype_id = fg.genotype_id
left join
feature f
on f.feature_id = fg.feature_id
left join cvterm fc
on fc.cvterm_id = f.type_id
left join feature_relationship fp
on f.feature_id = fp.subject_id
left join
feature fpo
on fpo.feature_id = fp.object_id
left join cvterm fpoc
on fpoc.cvterm_id = fp.type_id
left join cvterm cvo
on
cvo.cvterm_id = fpo.type_id
left join
(
select f.feature_id, f.name locus, c.name association_type, fs.feature_id gene_id, fs.name gene_name, cvs.name gene_type, fpr.value gene_full_name from feature_relationship fpg
join feature f
on f.feature_id = fpg.object_id
join cvterm c
on c.cvterm_id = fpg.type_id
join
feature fs
on fs.feature_id = fpg.subject_id
join 
cvterm cvs
on cvs.cvterm_id = fs.type_id
left join featureprop fpr
on fs.feature_id = fpr.feature_id
join cvterm cfp 
on cfp.cvterm_id = fpr.type_id and cfp.name = 'full_name'
where c.name = 'part_of' and cvs.name='mRNA'
) V
on V.feature_id = fpo.feature_id
where s.name in (SELECT current_setting('global.germplasm_name')) and fc.name = 'allele' and fpoc.name = 'allele_of' and cvo.name = 'gene';




-- LOCUS/GENE ASSOCIATIONS
select f.feature_id, f.name locus, c.name association_type, fs.name gene_name, cvs.name gene_type from feature_relationship fpg
join feature f
on f.feature_id = fpg.object_id
join cvterm c
on c.cvterm_id = fpg.type_id
join
feature fs
on fs.feature_id = fpg.subject_id
join 
cvterm cvs
on cvs.cvterm_id = fs.type_id
where f.name = 'AT1G51680' and c.name = 'part_of' and cvs.name='mRNA';

--GERMPLASM AND ASSOCIATED LOCUS/GENES/CURATOR_SUMMARY
select s.name germplasm_name, fpo.name locus, gene_to_locus_association_type, v.gene_name genes_names, v.curator_summary from feature_genotype fg 
join 
stock_genotype sg
on sg.genotype_id = fg.genotype_id
left join
cvterm sg_cv
on sg_cv.cvterm_id = sg.cvterm_id
join stock s
on s.stock_id = sg.stock_id
join 
cvterm fgc
on fgc.cvterm_id = fg.cvterm_id 
join 
genotype g
on g.genotype_id = fg.genotype_id
left join
feature f
on f.feature_id = fg.feature_id
left join cvterm fc
on fc.cvterm_id = f.type_id
left join feature_relationship fp
on f.feature_id = fp.subject_id
left join
feature fpo
on fpo.feature_id = fp.object_id
left join cvterm fpoc
on fpoc.cvterm_id = fp.type_id
left join cvterm cvo
on
cvo.cvterm_id = fpo.type_id
left join
(
select f.feature_id, f.name locus, c.name gene_to_locus_association_type, fs.feature_id gene_id, fs.name gene_name, cvs.name gene_type, fpr.value curator_summary from feature_relationship fpg
join feature f
on f.feature_id = fpg.object_id
join cvterm c
on c.cvterm_id = fpg.type_id
join
feature fs
on fs.feature_id = fpg.subject_id
join 
cvterm cvs
on cvs.cvterm_id = fs.type_id
left join featureprop fpr
on fs.feature_id = fpr.feature_id
join cvterm cfp 
on cfp.cvterm_id = fpr.type_id and cfp.name = 'curator_summary'
where c.name = 'part_of' and cvs.name='mRNA'
) V
on V.feature_id = fpo.feature_id
where s.name in (SELECT current_setting('global.germplasm_name'))  and fc.name = 'allele' and fpoc.name = 'allele_of' and cvo.name = 'gene';

--PHENOTYPE FOR A GIVEN LOCUS
select f."name" locus, fo."name" allele, pt.value phenotype from feature_relationship fp 
join feature f
on f.feature_id = fp.object_id
join feature fo
on fo.feature_id = fp.subject_id
join feature_phenotype fpp
on
fpp.feature_id = fo.feature_id
join phenotype pt
on pt.phenotype_id = fpp.phenotype_id
and f.name = 'AT1G51680';

--GERMPLASM/PHENOTYPE/LOCUS ASSOSIATIONS
select s.name germplasm_name, pt.value phenotype, pt.uniquename phenotype_accession, cp.name as attribute, ca.name evidence_type, p.uniquename publication, p.pyear, p.title, fa.name allele_feature_name, fc.name feature_type, fl.name locus, cl.name locus_feature_type from stock_phenotype stp
join phenotype pt
on pt.phenotype_id = stp.phenotype_id
join stock s
on s.stock_id = stp.stock_id
join
cvterm ca
on ca.cvterm_id = pt.assay_id
join
cvterm cp
on cp.cvterm_id = pt.attr_id 
left
join feature_phenotype fpp
on
fpp.phenotype_id = pt.phenotype_id
left join
feature fa
on 
fa.feature_id = fpp.feature_id
left join
cvterm fc
on fc.cvterm_id = fa.type_id
left join
feature_relationship fp
on fa.feature_id = fp.subject_id
left join feature fl
on 
fl.feature_id = fp.object_id
left join 
cvterm cl
on 
cl.cvterm_id = fl.type_id
left join
phenstatement ps
on 
ps.phenotype_id = fpp.phenotype_id
left join
phendesc pd
on ps.genotype_id = pd.genotype_id
left join
pub p
on p.pub_id = ps.pub_id
where s.name in (SELECT current_setting('global.germplasm_name')) and cl.name = 'gene';

-- GENOMIC FEATURES associated with GERMPLASM POLYMORHISM IN QUESTION

select g.genotype_id, c.name genotype_type,  g.uniquename genotype_unique_name, cf.name genotype_to_feature_association_type, f.name feature_name, ft.name feature_type from feature_genotype fg
join genotype g
on fg.genotype_id = g.genotype_id
join cvterm c
on c.cvterm_id = g.type_id
join cvterm cf
on cf.cvterm_id = fg.cvterm_id
join feature f on
f.feature_id = fg.feature_id
join
cvterm ft
on ft.cvterm_id = f.type_id
join
stock_genotype sg
on sg.genotype_id = g.genotype_id
join
stock s
on s.stock_id = sg.stock_id
where 
s.name in (SELECT current_setting('global.germplasm_name'))
order by fg."rank";

-- ALLELE Chromosome

select g.genotype_id, c.name genotype_type,  g.uniquename genotype_unique_name, cf.name genotype_to_feature_association_type, coalesce(chr_f.name, 'N/A') chromosome, f.name feature_name, ft.name feature_type from feature_genotype fg
join genotype g
on fg.genotype_id = g.genotype_id
join cvterm c
on c.cvterm_id = g.type_id
join cvterm cf
on cf.cvterm_id = fg.cvterm_id
join feature f on
f.feature_id = fg.feature_id
join
cvterm ft
on ft.cvterm_id = f.type_id
join
stock_genotype sg
on sg.genotype_id = g.genotype_id
join
stock s
on s.stock_id = sg.stock_id
left join feature chr_f
on chr_f.feature_id = fg.chromosome_id
where 
s.name in (SELECT current_setting('global.germplasm_name')) and ft.name = 'allele'
order by fg."rank";


--ALLELE DETAILS - CAUSED BY INSERTION

select f_chr.name chromosome, cb.name allele_feature_type, fs.name allele, cfp.name association_type, fo.name feature_name, co.name caused_by_feature_type from feature_relationship fp
join feature fo
on fo.feature_id = fp.object_id
join
feature fs
on fs.feature_id = fp.subject_id
join
cvterm cfp
on cfp.cvterm_id = fp.type_id
join 
cvterm co
on
co.cvterm_id = fo.type_id
join
cvterm cb
on cb.cvterm_id = fs.type_id
join feature_genotype fg
on fg.feature_id = fs.feature_id
join genotype g
on g.genotype_id = fg.genotype_id
join stock_genotype sg
on sg.genotype_id = fg.genotype_id
join stock s 
on s.stock_id = sg.stock_id
left join 
feature f_chr
on f_chr.feature_id = fg.chromosome_id
where s.name in (SELECT current_setting('global.germplasm_name')) and cfp.name = 'caused_by_insertion';
 
-- ASSOCIATED ALLELE GENOMIC FEATURES
select cb.name subject_feature_type, fs.uniquename subject_feature, cfp.name association_type, fo.name feature_name, co.name object_feature_type from feature_relationship fp
join feature fo
on fo.feature_id = fp.object_id
join
feature fs
on fs.feature_id = fp.subject_id
join
cvterm cfp
on cfp.cvterm_id = fp.type_id
join 
cvterm co
on
co.cvterm_id = fo.type_id
join
cvterm cb
on cb.cvterm_id = fs.type_id
join feature_genotype fg
on fg.feature_id = fs.feature_id
join genotype g
on g.genotype_id = fg.genotype_id
join stock_genotype sg
on sg.genotype_id = fg.genotype_id
join stock s 
on s.stock_id = sg.stock_id
where s.name in (SELECT current_setting('global.germplasm_name'));

-- ALLELE ASSOCIATED FLANKING REGION
select fo.uniquename flanking_region, co.name object_feature_type, fo.residues , fo.seqlen, db.name || ':' || dbx.accession accession, db.urlprefix || '' || dbx.accession external_reference, cfp.name association_type , fs.uniquename subject_feature, cb.name subject_feature_type from feature_relationship fp
join feature fo
on fo.feature_id = fp.object_id
join
feature fs
on fs.feature_id = fp.subject_id
join
cvterm cfp
on cfp.cvterm_id = fp.type_id
join 
cvterm co
on
co.cvterm_id = fo.type_id
join
cvterm cb
on cb.cvterm_id = fs.type_id
join feature_genotype fg
on fg.feature_id = fs.feature_id
join genotype g
on g.genotype_id = fg.genotype_id
join stock_genotype sg
on sg.genotype_id = fg.genotype_id
join stock s 
on s.stock_id = sg.stock_id
left join
feature_dbxref fdbx
on fo.feature_id = fdbx.feature_id
left join
dbxref dbx
on
dbx.dbxref_id = fdbx.dbxref_id
left join
db on
db.db_id = dbx.db_id
where s.name in (SELECT current_setting('global.germplasm_name')) and co.name = 'transposable_element_flanking_region';

-- FLANKING REGION INSERTION SITE LOCATION ON THE CHROMOSOME
select f_src.name chromosome, f_src.residues chromosome_residues, fs.uniquename, fl.fmin as start, fl.fmax as stop, fl.strand from feature_relationship fp
join feature fo
on fo.feature_id = fp.object_id
join
feature fs
on fs.feature_id = fp.subject_id
join
cvterm cfp
on cfp.cvterm_id = fp.type_id
join 
cvterm co
on
co.cvterm_id = fo.type_id
join
cvterm cb
on cb.cvterm_id = fs.type_id
join feature_genotype fg
on fg.feature_id = fs.feature_id
join genotype g
on g.genotype_id = fg.genotype_id
join stock_genotype sg
on sg.genotype_id = fg.genotype_id
join stock s 
on s.stock_id = sg.stock_id
left join featureloc fl
on fs.feature_id = fl.feature_id
left join
feature f_src
on fl.srcfeature_id = f_src.feature_id
where s.name in (SELECT current_setting('global.germplasm_name')) and cb.name = 'transposable_element_insertion_site' and cfp.name = 'associated_with'  and co.name = 'transposable_element_flanking_region';


-- FLANKING REGION ANNOTATION
select fo.uniquename flanking_region, co.name feature_type, fa.property_type, fa.value, fa.publication, fa.submitter, fa.date from feature_relationship fp
join feature fo
on fo.feature_id = fp.object_id
join
feature fs
on fs.feature_id = fp.subject_id
join
cvterm cfp
on cfp.cvterm_id = fp.type_id
join 
cvterm co
on
co.cvterm_id = fo.type_id
join
cvterm cb
on cb.cvterm_id = fs.type_id
join feature_genotype fg
on fg.feature_id = fs.feature_id
join genotype g
on g.genotype_id = fg.genotype_id
join stock_genotype sg
on sg.genotype_id = fg.genotype_id
join stock s 
on s.stock_id = sg.stock_id
left join
feature_dbxref fdbx
on fo.feature_id = fdbx.feature_id
left join
dbxref dbx
on
dbx.dbxref_id = fdbx.dbxref_id
join
db on
db.db_id = dbx.db_id
left join
(
select f.feature_id, f.name feature_name, cf.name feature_type, c.name property_type, fp.value, p.uniquename publication, pt.surname submitter, pt.date_created date from featureprop fp
join
feature f
on f.feature_id = fp.feature_id
join cvterm cf
on cf.cvterm_id = f.type_id
join cvterm c on
c.cvterm_id = fp.type_id
left join
featureprop_pub fpp
on fp.featureprop_id = fpp.featureprop_id
left join
pub p
on p.pub_id = fpp.pub_id
left join 
pub_dbxref pdbx
on pdbx.pub_id = p.pub_id
left join dbxref dbx
on dbx.dbxref_id = pdbx.dbxref_id
left join db
on db.db_id = dbx.db_id
left join
pubauthor pt
on pt.pub_id = p.pub_id
) fa
on fa.feature_id = fo.feature_id
where s.name in (SELECT current_setting('global.germplasm_name')) and co.name = 'transposable_element_flanking_region';

--ALLELE ATTRIBUTION
select fo.feature_id allele_feature_id, fo.name allele, att.attribution_type, att.submitter_name, att.date, s.name germplasm_name from feature_relationship fp 
join feature f
on f.feature_id = fp.object_id
join feature fo
on fo.feature_id = fp.subject_id
join feature_genotype fg
on fg.feature_id = fo.feature_id
join genotype g
on fg.genotype_id = g.genotype_id
join stock_genotype sg
on sg.genotype_id = g.genotype_id
join stock s
on s.stock_id = sg.stock_id
join cvterm fc
on fc.cvterm_id = f.type_id
join cvterm fco
on fco.cvterm_id = fo.type_id
left join
(
select f.feature_id, c.name attribution_type, ct.name submitter_name, ft.date_created date, p.uniquename, p.title, p.pyear, db.urlprefix || dbx.accession as url, dbx.accession from feature_attribution ft
join feature f
on ft.feature_id = f.feature_id
join cvterm c
on c.cvterm_id = ft.type_id
join
contact ct
on ct.contact_id = ft.contact_id
left join
pub p
on p.pub_id = ft.pub_id
left join 
pub_dbxref pdbx
on pdbx.pub_id = p.pub_id
join dbxref dbx
on dbx.dbxref_id = pdbx.dbxref_id
join db
on db.db_id = dbx.db_id
) att
on
att.feature_id = fo.feature_id
where s.name in (SELECT current_setting('global.germplasm_name')) and fco.name = 'allele' and fc.name = 'gene';


--ASSOCIATED REFERENCE POLYMORPHISM 
select cb.name subject_feature_type, fs.uniquename subject_feature, cfp.name association_type, fo.name feature_name, co.name object_feature_type, os.name reference_ecotype, fo.residues polymorphic_sequence, fo.seqlen sequence_length from feature_relationship fp
join feature fo
on fo.feature_id = fp.object_id
join
feature fs
on fs.feature_id = fp.subject_id
join
cvterm cfp
on cfp.cvterm_id = fp.type_id
join 
cvterm co
on
co.cvterm_id = fo.type_id
join
cvterm cb
on cb.cvterm_id = fs.type_id
join feature_genotype fg
on fg.feature_id = fs.feature_id
join genotype g
on g.genotype_id = fg.genotype_id
join stock_genotype sg
on sg.genotype_id = fg.genotype_id
join stock s 
on s.stock_id = sg.stock_id
left join
organism o
on o.organism_id = fo.organism_id
left join
stock os
on os.stock_id = o.stock_id
where s.name in (SELECT current_setting('global.germplasm_name')) and co.name='reference_allele' and cfp.name = 'associated_with';

--REFRENCE ALLELE ATTRIBUTION
select f.name reference_allele, fc.name feature_type,  att.attribution_type, att.submitter_name, att.date, att.uniquename publication, att.url, att.accession, s.name germplasm_name from feature_relationship fp 
join feature f
on f.feature_id = fp.object_id
join feature fo
on fo.feature_id = fp.subject_id
join feature_genotype fg
on fg.feature_id = fo.feature_id
join genotype g
on fg.genotype_id = g.genotype_id
join stock_genotype sg
on sg.genotype_id = g.genotype_id
join stock s
on s.stock_id = sg.stock_id
join cvterm fc
on fc.cvterm_id = f.type_id
join cvterm fco
on fco.cvterm_id = fo.type_id
left join
(
select f.feature_id, f.type_id feature_type_id, c.name attribution_type, ct.name submitter_name, ft.date_created date, p.uniquename, p.title, p.pyear, db.urlprefix || dbx.accession as url, dbx.accession from feature_attribution ft
join feature f
on ft.feature_id = f.feature_id
join cvterm c
on c.cvterm_id = ft.type_id
join
contact ct
on ct.contact_id = ft.contact_id
left join
pub p
on p.pub_id = ft.pub_id
left join 
pub_dbxref pdbx
on pdbx.pub_id = p.pub_id
left join dbxref dbx
on dbx.dbxref_id = pdbx.dbxref_id
left join db
on db.db_id = dbx.db_id
) att
on
att.feature_id = f.feature_id and f.type_id = att.feature_type_id
where s.name in (SELECT current_setting('global.germplasm_name')) and fc.name='reference_allele';
