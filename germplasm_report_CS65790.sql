--GERMPLASM BASE INFO
SELECT
	s.name germplasm_name, cs.name germplasm_type,
	db.urlprefix || dbx.accession germplasm_tair_accession_url,
	dbx.accession germplasm_tair_accession,
	s.description, o.genus || ' ' || o.species taxon
FROM
	stock s
		LEFT JOIN
		stock_genotype sg
		ON
		s.stock_id = sg.stock_id
		LEFT JOIN
		genotype g
		ON
		g.genotype_id = sg.genotype_id JOIN cvterm c
		ON
		c.cvterm_id = g.type_id JOIN dbxref dbx
		ON
		s.dbxref_id = dbx.dbxref_id JOIN db
		ON
		db.db_id = dbx.db_id JOIN dbxref dbx_p
		ON
		g.dbxref_id = dbx_p.dbxref_id JOIN db db_p
		ON
		db_p.db_id = dbx_p.db_id
		join organism o
		on
		o.organism_id = s.organism_id
		join cvterm cs 
		on cs.cvterm_id = s.type_id
		
WHERE
	s.name = 'CS65790';

-- Other Names - NASC Stock Number
select s.name germplasm_name, sn.name nasc_stock_number from stock_synonym stn
join 
synonym sn
on stn.synonym_id = sn.synonym_id
join
stock s
on s.stock_id = stn.stock_id
and s.name = 'CS65790';

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
	s.name = 'CS65790'
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
	s.name = 'CS65790' and cv.name = 'mutagen_type'
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
	s.name = 'CS65790' and cv.name = 'chromosomal_constitution' and cp.name = 'ploidy' 
ORDER BY
	sv.rank;

-- OTHER GERMPLASM PROPERTIES

select s.name, c.name as property_type, sp.value from stock s
join stockprop sp
on s.stock_id = sp.stock_id
join cvterm c
on sp.type_id = c.cvterm_id
where s.name = 'CS65790'
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
where so.name = 'CS65790' and c.name  like  '%background_accession%';

-- all parent lines
SELECT str.stock_relationship_id, sbc.name as germplasm_type, sb.uniquename as germplasm_name, ' is a ' || c.name as relationship, so.name as parent_line, sbc.name parent_type,  v.locus ,cc.name generative_method from STOCK_RELATIONSHIP str
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
join 
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
where s.name = 'CS65790' and fc.name = 'gene'
) V
ON
V.stock_id = sb.stock_id
where sb.name = 'CS65790' and c.name = 'offspring_of' order by str.rank;

-- GENETIC CONTEXT
-- locus and allele feature accociated with the germplasm 
select distinct f."name" locus, fo."name" allele,  s.name germplasm_name from feature_relationship fp 
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
where s.name = 'CS65790' and fco.name = 'allele' and fc.name = 'gene';
