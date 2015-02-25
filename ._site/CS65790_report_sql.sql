-- GERMPLASM and POLYMORHISM ASSOCIATIONS
select s.name germplasm_name, db.urlprefix || dbx.accession germplasm_tair_accession_url,
	dbx.accession germplasm_tair_accession, g.name polymorhism_name, g.description, c.name polymorphism_type ,
	db_p.urlprefix || dbx_p.accession polymorphism_tair_accession_url,
	dbx_p.accession polymorphism_tair_accession
		from stock s
left join
stock_genotype sg
on s.stock_id = sg.stock_id
left join genotype g
on g.genotype_id = sg.genotype_id
join cvterm c
on c.cvterm_id = g.type_id
join dbxref dbx on
	s.dbxref_id = dbx.dbxref_id
	join db on db.db_id = dbx.db_id
	join dbxref dbx_p on
	g.dbxref_id = dbx_p.dbxref_id
	join db db_p on db_p.db_id = dbx_p.db_id
where s.name = 'CS65790';

--GERMPLASM ADDITIONAL TERMS
SELECT
	s.name,
	s.description,
	cv.cv_id,
	cv.name stock_category,
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
	sv.stock_id = 3
ORDER BY
	sv.rank;


--Find polymorhism(genotype) in question 
select g.uniquename, g.description, c.name genotype_type from genotype g 
join cvterm c
on c.cvterm_id = g.type_id
where g.uniquename = '4CL1-1';

-- List additional terms describing polymorphism in question
SELECT
	s.name,
	s.description,
	cv.cv_id,
	cv.name genotype_category,
	c.cvterm_id,
	case when sv.is_not then 'is not a' else 'is a' end as relationship_type,
	c.name assigned_term
FROM
	genotype_cvterm sv JOIN cvterm c
	ON
	c.cvterm_id = sv.cvterm_id JOIN cv
	ON
	cv.cv_id = c.cv_id JOIN genotype s
	ON
	s.genotype_id = sv.genotype_id
	where sv.genotype_id = 1;


-- List Additional Properties of Genotype in question
select g.genotype_id, g.name, c.name, gp.value from genotypeprop gp
join cvterm c
on c.cvterm_id = gp.type_id
join
genotype g
on g.genotype_id = gp.genotype_id
order by gp.rank;

--List all polymorphic features accociated with polymorphism in question
select g.genotype_id, g.uniquename polymorhism_name, c.name genotype_type, f.name feature_name, ft.name feature_type, cf.name genotype_to_association_type, fg.rank feature_rank, s.name background_accession from feature_genotype fg
join genotype g
on fg.genotype_id = g.genotype_id
join cvterm c
on c.cvterm_id = g.type_id
join cvterm cf
on cf.cvterm_id = fg.cvterm_id
join stock s
on s.stock_id = fg.background_accession_id
join feature f on
f.feature_id = fg.feature_id
join
cvterm ft
on ft.cvterm_id = f.type_id
where 
 g.genotype_id = 1
 order by fg."rank";
 
 -- List all additional terms desribing polymorphic features
select g.genotype_id, g.uniquename polymorhism_name, f.name feature_name, cc.name feature_type, c.name polymorphism_feature_category, cv.name term_type, fc.name assigned_term from feature_genotype_cvterm fgc
join
feature_genotype fg
on fg.feature_genotype_id = fgc.feature_genotype_id
join
cvterm c
on c.cvterm_id = fg.cvterm_id
join
cvterm fc
on fc.cvterm_id = fgc.cvterm_id
join genotype g
on
g.genotype_id = fg.genotype_id
join feature f
on f.feature_id = fg.feature_id
join cvterm cc
on cc.cvterm_id = f.type_id
join
cv on cv.cv_id = fc.cv_id order by fgc.rank;

-- List all additional properties associated with  poymorphic features
select fpg.feature_genotype_prop_id, g.genotype_id, g.uniquename polymorhism_name, f.name feature_name, fg_t.name feature_type, ffc.name polymorphic_property_type, fpg.value from feature_genotype_prop fpg
left
join
feature_genotype fg
on fg.feature_genotype_id = fpg.feature_genotype_id
join genotype g
on
g.genotype_id = fg.genotype_id
left
join feature f
on f.feature_id = fg.feature_id
left
join cvterm cc
on cc.cvterm_id = f.type_id
left
join cvterm ffc
on ffc.cvterm_id = fpg.type_id
join cvterm fg_t 
on 
fg_t.cvterm_id = fg.cvterm_id
order by fg.rank, f.name, fpg.rank;


-- Find polymorhism sequence feature in question 
select f.feature_id, c.name feature_type, f.name feature_name from feature f
join cvterm c
on c.cvterm_id = f.type_id
where f."name" = 'SALK_142526.46.30.X';

--locus associated with polymorshism feature SVP (SEQUENCE VARIANT POLYMORHISM)
select  f1.name polymorhic_feature_name, 'is_a' relationship_type, cf.name relationship, f2.name locus_feature_name from feature_relationship fp
join feature f1
on f1.feature_id = fp.subject_id
join feature f2
on f2.feature_id = fp.object_id
join cvterm cf
on cf.cvterm_id = fp.type_id
where fp.subject_id = 779222;

--SVP sequence feature (polymorhic fragment location) on the chomosome
select f_src.name chromosome, f_src.residues, f.name feature_name, f.residues polymorphic_sequence, f.seqlen sequence_length, fl.fmin as start, fl.fmax as stop, fl.strand from featureloc fl
join feature f_src 
on fl.srcfeature_id = f_src.feature_id
join cvterm cf
on cf.cvterm_id = f_src.type_id
join feature f
on f.feature_id = fl.feature_id
where fl.feature_id = 779222;

--INFORMATION about all sequence features associated with polymorhism
select f.name feature_name, f.residues polymorphic_sequence, f.seqlen sequence_length, fl.fmin as start, fl.fmax as stop, fl.strand from 
feature f
left
join featureloc fl
on f.feature_id = fl.feature_id
where f.feature_id in (779222);



-- FEATURE ANNOTATION REPORT

SELECT
	s.name,
	cv.name feature_type,
	case when sv.is_not then 'is not a' else 'is a' end as relationship_type,
	c.name assigned_term,
	db.urlprefix || dbx.accession external_accession_url,
	dbx.accession external_accession
FROM
	feature_cvterm sv JOIN cvterm c
	ON
	c.cvterm_id = sv.cvterm_id JOIN cv
	ON
	cv.cv_id = c.cv_id JOIN feature s
	ON
	s.feature_id = sv.feature_id
	left join feature_dbxref fd
	on fd.feature_id = s.feature_id
	join dbxref dbx on
	fd.dbxref_id = dbx.dbxref_id
	join db on db.db_id = dbx.db_id
		where sv.feature_id in (779222);
	

select sp.stock_relationship_id, sb.name, c.name relationship_type, ob.name, sbg.uniquename background_accession, stv_c.name relationship_annotation, sp.rank from stock_relationship sp
join 
cvterm c on c.cvterm_id = sp.type_id
join 
stock sb
on sb.stock_id = sp.subject_id 
join stock ob
on ob.stock_id = sp.object_id
join stock sbg
on sbg.stock_id = sp.background_accession_id
left join stock_relationship_cvterm stv
on 
sp.stock_relationship_id = stv.stock_relationship_id
left join cvterm stv_c
on stv_c.cvterm_id = stv.cvterm_id
where sb.name = 'CS65790'
order by sp. rank;



