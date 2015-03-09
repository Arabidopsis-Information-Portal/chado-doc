# Araport Chado SQL

* **[General Usage](#general-usage)**

* **[Germplasm Report](#germplasm-report)**
 
 * [Germplasm Report Settings](#germplasm-report-settings)
 * [Germplasm Information](#germplasm-info)
 * [Germplasm/Locus Associations](#germplasm-locus)
 * [Germplasm/Phenotype Associations](#germplasm-phenotype)
 * [Germplasm Provenance](#germplasm-provenance)

* **[Polymorphism/Genetic Context Report](#genetic-context)**

	* [Polymorphism Information](#poly-info)
	* [Allele Information](#allele-info)
	* [Allele/Genomic Features Associations](#allele-genomic)
	* [Allele Provenance](#allele-provenance)
	* [Allele/Phenotype Associations](#allele-phenotype)


* **[Precompiled SQL Scripts](#sql-scripts)**
	* [CS65790](#CS65790)
	* [CS6131](#CS65790)


##<a name="general-usage"></a>General Usage

The document contains sql snippets to display the content of the Araport Chado database. 

The sql snippets are under active development, and might not cover all data context existing in the database. Please, submit requests for the snippets corrections and new features to ibelyaev@jcvi.org.

The sql snippets have been developed to display germplasm/allele/phenotype information by known germpalsm name.

To successfully retrieve the related pieces of the information, please, run the [global sql snippet](#germplasm-report-settings) to set the name of the germplasm in question, first.

Set germplasm name

```
plsql> set global.germplasm_name= 'CS65790';
```
Validate the germplasm name has been set

```
plsql>SELECT current_setting('global.germplasm_name'); 
```

Thank you!

##<a name="germplasm-report-settings"></a>Germplasm Report Settings

Set germplasm name

```
plsql> set global.germplasm_name= 'CS65790';
```

Validate the germplasm name has been set

```
plsql>SELECT current_setting('global.germplasm_name'); 
```
##<a name="germplasm-report"></a>Germplasm Report

###<a name="germplasm-info"></a>Germplasm Information

```
SELECT
	s.name germplasm_name, c.name germplasm_type,
	db.urlprefix || dbx.accession germplasm_tair_accession_url,
	dbx.accession germplasm_tair_accession,
	s.description, o.genus || ' ' || o.species taxon, n.object_stock_name || '' || object_stock_uniquename accession
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
```
#### SQL Output

| germplasm_name | germplasm_type  | germplasm_tair_accession_url                                            | germplasm_tair_accession | description                                                                    | taxon                | accession |
|----------------|-----------------|-------------------------------------------------------------------------|--------------------------|--------------------------------------------------------------------------------|----------------------|-----------|
| CS65790        | individual_line | http://arabidopsis.org/servlets/TairObject?type=germplasm&id=6530293244 | 6530293244               | confirmed line isolated from original SALK line; homozygous for the insertion. | Arabidopsis thaliana | null      |

### Germplasm TAIR Accessions

```
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
```

#### SQL Output

| germplasm_name | tair_accession            | accession_url                                                           |
|----------------|---------------------------|-------------------------------------------------------------------------|
| CS65790        | TAIR Stock:4501957790     | http://arabidopsis.org/servlets/TairObject?type=stock&id=4501957790     |
| CS65790        | TAIR:Stock:6530293190     | null                                                                    |
| CS65790        | TAIR Germplasm:6530293244 | http://arabidopsis.org/servlets/TairObject?type=germplasm&id=6530293244 |


### NASC Stock Number

```
select s.name germplasm_name, sn.name nasc_stock_number from stock_synonym stn
join 
synonym sn
on stn.synonym_id = sn.synonym_id
join
stock s
on s.stock_id = stn.stock_id
and s.name in (SELECT current_setting('global.germplasm_name'));
```
### SQL Output
| germplasm_name | nasc_stock_number |
|----------------|-------------------|
| CS65790        | N65790            |

### Germplasm Descriptor

### Associated Annotation Terms
```
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
	
```
#### SQL Output

| germplasm_name | description                                                                    | term_type                | relationship_type | assigned_term     |
|----------------|--------------------------------------------------------------------------------|--------------------------|-------------------|-------------------|
| CS65790        | confirmed line isolated from original SALK line; homozygous for the insertion. | germplasm_type           | is a              | mutant            |
| CS65790        | confirmed line isolated from original SALK line; homozygous for the insertion. | germplasm_type           | is not a          | natural_variant   |
| CS65790        | confirmed line isolated from original SALK line; homozygous for the insertion. | germplasm_type           | is a              | has_foreign_dna   |
| CS65790        | confirmed line isolated from original SALK line; homozygous for the insertion. | chromosomal_constitution | is not a          | aneuploid         |
| CS65790        | confirmed line isolated from original SALK line; homozygous for the insertion. | germplasm_type           | is a              | has_polymorphisms |
| CS65790        | confirmed line isolated from original SALK line; homozygous for the insertion. | mutagen_type             | is a              | t-dna_insertion   |

### Germplasm Mutagen

```
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
```
#### SQL Output

| germplasm_name | term_type    | mutagen         |
|----------------|--------------|-----------------|
| CS65790        | mutagen_type | t-dna_insertion |


### Chromosomal Constitution
```
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
```
#### SQL Output

| germplasm_name | term_type                | relationship_type | aneploid  | ploidy_property | ploidy_value |
|----------------|--------------------------|-------------------|-----------|-----------------|--------------|
| CS65790        | chromosomal_constitution | is not a          | aneuploid | ploidy          | 2            |

#### Other Germplasm Properties 

```
select s.name, c.name as property_type, sp.value from stock s
join stockprop sp
on s.stock_id = sp.stock_id
join cvterm c
on sp.type_id = c.cvterm_id
where s.name in (SELECT current_setting('global.germplasm_name'))
order by rank;
```

#### SQL Output

| name    | property_type      | value         |
|---------|--------------------|---------------|
| CS65790 | ploidy             | 2             |
| CS65790 | date_entered       | 10/1/10 14:05 |
| CS65790 | date_last_modified | 10/1/10 0:00  |


### Pedigree

#### Germplasm background accession

```
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
```

#### SQL Output

| type    | background_accession | relationship                 | germplasm_name | germplasm_type  |
|---------|----------------------|------------------------------|----------------|-----------------|
| ecotype | Col-0                | is a background_accession_of | CS65790        | individual_line |



### Parent Lines

```
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
```
#### SQL Output
| stock_relationship_id | germplasm_type  | germplasm_name | relationship      | parent_line |
|-----------------------|-----------------|----------------|-------------------|-------------|
| 1                     | individual_line | CS65790        | is a offspring_of | SALK_142526 |


#### Parent Lines/Associated Locus

```
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
```
#### SQL Output

| stock_relationship_id | germplasm_type  | germplasm_name | relationship      | parent_line | parent_type     | parent_locus_associations | generative_method |
|-----------------------|-----------------|----------------|-------------------|-------------|-----------------|---------------------------|-------------------|
| 2                     | individual_line | CS65790        | is a offspring_of | CS6000      | individual_line | AT1G51680                 | null              |
| 1                     | individual_line | CS65790        | is a offspring_of | SALK_142526 | individual_line | AT1G51680                 | puritative        |


###<a name="germplasm-locus"></a>Germplasm/Locus Associations

#### Locus/Allele Feature associated with the germplasm

```
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
```

#### SQL Output
| locus     | allele | property           | mutagen         | germplasm_name |
|-----------|--------|--------------------|-----------------|----------------|
| AT1G51680 | 4CL1-1 | origin_of_mutation | t-dna_insertion | CS65790        |


###<a name="germplasm-phenotype"></a>Germplasm/Phenotype Associations

#### Phenotype Associated with the germplasm
```
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
```

#### SQL Output

| germplasm_name | phenotype             | phenotype_accession | attribute   | evidence_type |
|----------------|-----------------------|---------------------|-------------|---------------|
| CS65790        | No visible phenotype. | 6054:6030203590     | unspecified | no_evidence   |

#### Phenotype Publication by Germplasm Name

```
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
```

#### SQL Output
| phenotype_id | description           | publication  | pyear | title |
|--------------|-----------------------|--------------|-------|-------|
| 4            | No visible phenotype. | unattributed | null  | null  |


###<a name="germplasm-provenance"></a>Germplasm Provenance

#### Germplasm Publication

```
select s.name germplasm_name, coalesce(p.uniquename, 'N/A') publication, coalesce(p.title, 'N/A') as title,  coalesce(p.pyear, 'N/A') as year from stock s
left join
stock_pub sp
on s.stock_id = sp.stock_id
left join pub p
on 
p.pub_id = sp.pub_id
where s.name in (SELECT current_setting('global.germplasm_name'));
```

#### SQL Output
| germplasm_name | publication | title | year |
|----------------|-------------|-------|------|
| CS65790        | N/A         | N/A   | N/A  |


#### Germplasm Attribution
```
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
```

#### SQL Output

| germplasm_name | attribution_type | submitter_name                         | date                |
|----------------|------------------|----------------------------------------|---------------------|
| CS65790        | submitted_by     | Arabidopsis Biological Resource Center | 2010-10-01 23:00:00 |


###<a name="genetic-context"></a>Polymorphism/Genetic Context Report

###<a name="poly-info"></a>Polymorphism Information
```
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
```

#### SQL Output
| germplasm_name | genotype_name | genotype_type   | genotype_uniquename                  | genotype_description                                                                                                                                                                                                                                                                                                         | zygosity   | tair_accession_url                                                        | tair_accession |
|----------------|---------------|-----------------|--------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------|---------------------------------------------------------------------------|----------------|
| CS65790        | 4CL1-1        | t-dna_insertion | SALK_142526.46.30.X:AT1G51680:4CL1-1 | PCR was performed on Arabidopsis thaliana lines each of which contains one or more TDNA insertion elements. The resultant fragment for each line was directly sequenced to determine the genomic sequence at the site of insertion. Details of the protocols used can be found at http://signal.salk.edu/tdna_protocols.html | homozygous | http://arabidopsis.org/servlets/TairObject?type=polymorphism&id=500201440 | 500201440      |

#### Polymorphism Properties

```
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
```

#### SQL Output
| genotype_name | property             | property_value |
|---------------|----------------------|----------------|
| 4CL1-1        | observable_phenotype | Yes            |
| 4CL1-1        | sequenced            | Yes            |
| 4CL1-1        | induced              | Yes            |
| 4CL1-1        | present              | Yes            |
| 4CL1-1        | obsolete             | No             |
| 4CL1-1        | date_entered         | 2003-05-03     |
| 4CL1-1        | date_last_modified   | 2010-10-20     |


#### Polymorphism  TAIR Accessions

```
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
```

| germplasm_name | genotype_name | tair_accession               | tair_accession_url                                                        |
|----------------|---------------|------------------------------|---------------------------------------------------------------------------|
| CS65790        | 4CL1-1        | TAIR Polymorphism:500201440  | http://arabidopsis.org/servlets/TairObject?type=polymorphism&id=500201440 |
| CS65790        | 4CL1-1        | TAIR:Polymorphism:1005711029 | null                                                                      |
| CS65790        | 4CL1-1        | TAIR:Polymorphism:1005409201 | null                                                                      |

#### Polymorphism Synonyms
```
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
```
#### SQL Output

| germplasm_name | genotype_name | tair_accession               | tair_accession_url                                                        |
|----------------|---------------|------------------------------|---------------------------------------------------------------------------|
| CS65790        | 4CL1-1        | TAIR Polymorphism:500201440  | http://arabidopsis.org/servlets/TairObject?type=polymorphism&id=500201440 |
| CS65790        | 4CL1-1        | TAIR:Polymorphism:1005711029 | null                                                                      |
| CS65790        | 4CL1-1        | TAIR:Polymorphism:1005409201 | null                                                                      |

#### Associated Clone Construct Type

```
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
```

#### SQL Output

| allele | property             | clone_construct_type | germplasm_name |
|--------|----------------------|----------------------|----------------|
| 4CL1-1 | clone_construct_type | simple_construct     | CS65790        |

###<a name="allele-info"></a>Allele Information

#### Locus and Allele Feature/Allele Mutagen associated with the germplasm polymorphisms

```
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
```

#### SQL Output
| locus     | allele | property           | mutagen         | germplasm_name |
|-----------|--------|--------------------|-----------------|----------------|
| AT1G51680 | 4CL1-1 | origin_of_mutation | t-dna_insertion | CS65790        |

#### Allele Mutagen
```
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
```

#### SQL Output
| allele | property           | mutagen         | germplasm_name |
|--------|--------------------|-----------------|----------------|
| 4CL1-1 | origin_of_mutation | t-dna_insertion | CS65790        |


     
#### Allele Mutation Site

```
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
```

#### SQL Output

| allele | property | mutation_site | germplasm_name |
|--------|----------|---------------|----------------|
| 4CL1-1 | null     | N/A           | CS65790        |


#### Allele Type
```
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
```
#### SQL Output
| allele | property | allele_type | germplasm_name |
|--------|----------|-------------|----------------|
| 4CL1-1 | null     | N/A         | CS65790        |


###<a name="allele-genomic"></a>Allele/Genomic Features Associations

### Locus/Allele/Genes Name/Full Name features associated with the germplasm 

```
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
```

#### SQL Output

| germplasm_name | genotype_name | relationship    | allele_name | association_type | zygocity   | locus     | genes_names | gene_full_name           |
|----------------|---------------|-----------------|-------------|------------------|------------|-----------|-------------|--------------------------|
| CS65790        | 4CL1-1        | associated_with | 4CL1-1      | allele_of        | homozygous | AT1G51680 | AT1G51680.1 | 4-coumarate:CoA ligase 1 |
| CS65790        | 4CL1-1        | associated_with | 4CL1-1      | allele_of        | homozygous | AT1G51680 | AT1G51680.2 | 4-coumarate:CoA ligase 1 |
| CS65790        | 4CL1-1        | associated_with | 4CL1-1      | allele_of        | homozygous | AT1G51680 | AT1G51680.3 | 4-coumarate:CoA ligase 1 |


### Locus/Allele/Genes & Curator Summary associated with the germplasm

```
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
```

#### SQL Output
| germplasm_name | locus     | gene_to_locus_association_type | genes_names | curator_summary                                                                                                                                                                                                                                                                                                                                                                  |
|----------------|-----------|--------------------------------|-------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| CS65790        | AT1G51680 | part_of                        | AT1G51680.1 | encodes an isoform of 4-coumarate:CoA ligase (4CL), which is involved in the last step of the general phenylpropanoid pathway. In addition to 4-coumarate, it also converts ferulate.  The catalytic efficiency was in the following (descending) order:  p-coumaric acid, ferulic acid, caffeic acid and 5-OH-ferulic acid. At4CL1 was unable to use sinapic acid as substrate. |
| CS65790        | AT1G51680 | part_of                        | AT1G51680.2 | encodes an isoform of 4-coumarate:CoA ligase (4CL), which is involved in the last step of the general phenylpropanoid pathway. In addition to 4-coumarate, it also converts ferulate.  The catalytic efficiency was in the following (descending) order:  p-coumaric acid, ferulic acid, caffeic acid and 5-OH-ferulic acid. At4CL1 was unable to use sinapic acid as substrate. |
| CS65790        | AT1G51680 | part_of                        | AT1G51680.3 | encodes an isoform of 4-coumarate:CoA ligase (4CL), which is involved in the last step of the general phenylpropanoid pathway. In addition to 4-coumarate, it also converts ferulate.  The catalytic efficiency was in the following (descending) order:  p-coumaric acid, ferulic acid, caffeic acid and 5-OH-ferulic acid. At4CL1 was unable to use sinapic acid as substrate. |

#### Genomic Features associated with the germplasm polymorphism in question
```
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
```

#### SQL Output
| chromosome | allele_feature_type | allele | association_type    | feature_name        | caused_by_feature_type |
|------------|---------------------|--------|---------------------|---------------------|------------------------|
| Chr1       | allele              | 4CL1-1 | caused_by_insertion | SALK_142526.46.30.X | t-dna_transposon       |

#### Associated Allele Genomic Features

```
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
```

#### SQL Output

| subject_feature_type                | subject_feature                                         | association_type    | feature_name                | object_feature_type                  |
|-------------------------------------|---------------------------------------------------------|---------------------|-----------------------------|--------------------------------------|
| transposable_element_insertion_site | SALK_142526.46.30.X:transposable_element_insertion_site | produced_by         | SALK_142526.46.30.X         | t-dna_transposon                     |
| transposable_element_insertion_site | SALK_142526.46.30.X:transposable_element_insertion_site | associated_with     | SALK_142526.46.30.X         | transposable_element_flanking_region |
| allele                              | 4CL1-1                                                  | allele_of           | AT1G51680                   | gene                                 |
| allele                              | 4CL1-1                                                  | caused_by_insertion | SALK_142526.46.30.X         | t-dna_transposon                     |
| allele                              | 4CL1-1                                                  | carried_in          | SALK_142526.46.30.X         | transposable_element_insertion_site  |
| allele                              | 4CL1-1                                                  | associated_with     | 4CL1-1:reference allele:Col | reference_allele                     |

#### Allele Associated Flanking Region

```
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
join
db on
db.db_id = dbx.db_id
where s.name in (SELECT current_setting('global.germplasm_name')) and co.name = 'transposable_element_flanking_region';
```

#### SQL Output
| flanking_region                                          | object_feature_type                  | residues                                                                                                                                                                                                                                                                                                                                                                                                                                                       | seqlen | accession                            | external_reference                          | association_type | subject_feature                                         | subject_feature_type                |
|----------------------------------------------------------|--------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------|--------------------------------------|---------------------------------------------|------------------|---------------------------------------------------------|-------------------------------------|
| SALK_142526.46.30.X:transposable_element_flanking_region | transposable_element_flanking_region | CTCCATCACCTGAGAAACTGCTTGTTCTTGTGGCGCCATTGTAAATAGTAAATATTGTGATATTCAAAGATTTAGGTGGAAAAAAAAGGTTGGTTTTTTTGGTTGTGTGAATTTTAGGCTTTGGCCTGAAGGAAACAGGAGTTGTATCGGAGGAGTTCATATAGACAATTCACCGGAGTAGACGGTGGGGTTGGTGAAAATGTTAGTGTTGTTGTTTCATGATTTTGCTGAGGGTGATTTTGTCATTTAATCTTTTTTGAGTATGGGTTTCTCAAATTTTCACGTTGCGTTTGGTAAGCTGCATTTCTTTCTTTTAAAATCACATAAACTAGTGGTAATATATTTATAAGCAAATTTGTATTTTTCTGAAAAATTAACTGGATTTTGTATTTTTCATAAACAAATTTCTTTGTTGAAATGTTATATTTTATTTATTTTTATGTTAA | 446    | Genbank Nucleotide database:CC180175 | http://www.ncbi.nlm.nih.gov/nucgss/CC180175 | associated_with  | SALK_142526.46.30.X:transposable_element_insertion_site | transposable_element_insertion_site |


#### Flanking Region Insertion Site Location on the chromosome

```
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
```

#### SQL Output

| chromosome | chromosome_residues | uniquename                                              | start    | stop     | strand |
|------------|---------------------|---------------------------------------------------------|----------|----------|--------|
| Chr1       | null                | SALK_142526.46.30.X:transposable_element_insertion_site | 19161426 | 19161871 | 1      |

#### Flanking Region Annotation

```
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
```

#### SQL Output
| flanking_region                                          | feature_type                         | property_type | value                                                                                                                           | publication                                                                                                                                   | submitter | date                |
|----------------------------------------------------------|--------------------------------------|---------------|---------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|-----------|---------------------|
| SALK_142526.46.30.X:transposable_element_flanking_region | transposable_element_flanking_region | annotation    | This is single pass sequence recovered from the left border of TDNA. This sequence lies within an annotated exon of At1g551680. | SALK_142526.46.30.x Arabidopsis thaliana TDNA insertion lines Arabidopsis thaliana genomic clone SALK_142526.46.30.x, genomic survey sequence | GenBank   | 2007-10-22 23:00:00 |


###<a name="allele-provenance"></a>Allele Provenance

#### Allele Feature Attribution

```
select fo.feature_id allele_feature_id, fo.name allele, att.attribution_type, att.submitter_name, att.date, att.uniquename publication, att.url, att.accession, s.name germplasm_name from feature_relationship fp 
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
```

#### SQL Output

| allele_feature_id | allele | attribution_type | submitter_name | date                | publication                                                                                                                                   | url                                         | accession | germplasm_name |
|-------------------|--------|------------------|----------------|---------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------|-----------|----------------|
| 779226            | 4CL1-1 | submitted_by     | GenBank        | 2007-10-22 23:00:00 | SALK_142526.46.30.x Arabidopsis thaliana TDNA insertion lines Arabidopsis thaliana genomic clone SALK_142526.46.30.x, genomic survey sequence | http://www.ncbi.nlm.nih.gov/nucgss/CC180175 | CC180175  | CS65790        |
| 779226            | 4CL1-1 | submitted_by     | Joseph Ecker   | 2007-10-22 23:00:00 | SALK_142526.46.30.x Arabidopsis thaliana TDNA insertion lines Arabidopsis thaliana genomic clone SALK_142526.46.30.x, genomic survey sequence | http://www.ncbi.nlm.nih.gov/nucgss/CC180175 | CC180175  | CS65790        |


#### Associated Reference Polymorphism
```
select cb.name subject_feature_type, fs.uniquename subject_feature, cfp.name association_type, fo.name feature_name, co.name object_feature_type, os.name reference_ecotype from feature_relationship fp
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
```

#### SQL Output

| subject_feature_type | subject_feature | association_type | feature_name                | object_feature_type | reference_ecotype |
|----------------------|-----------------|------------------|-----------------------------|---------------------|-------------------|
| allele               | 4CL1-1          | associated_with  | 4CL1-1:reference allele:Col | reference_allele    | COLUMBIA          |


#### Reference Allele Attribution
```
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
```

#### SQL Output
| reference_allele            | feature_type     | attribution_type | submitter_name | date                | publication | url  | accession | germplasm_name |
|-----------------------------|------------------|------------------|----------------|---------------------|-------------|------|-----------|----------------|
| 4CL1-1:reference allele:Col | reference_allele | submitted_by     | Joseph Ecker   | 2009-08-11 23:00:00 | null        | null | null      | CS65790        |



###<a name="allele-phenotype"></a>Allele/Phenotype Associations

#### Germplasm/Phenotype/Locus Associations
```
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
```

#### SQL Output
| germplasm_name | phenotype             | phenotype_accession | attribute   | evidence_type | publication  | pyear | title | allele_feature_name | feature_type | locus     | locus_feature_type |
|----------------|-----------------------|---------------------|-------------|---------------|--------------|-------|-------|---------------------|--------------|-----------|--------------------|
| CS65790        | No visible phenotype. | 6054|6030203590     | unspecified | no_evidence   | unattributed | null  | null  | 4CL1-1              | allele       | AT1G51680 | gene               |


##<a name="sql-scripts"></a>Precompiled SQL Scripts

###<a name="CS65790"></a>[CS65790](germplasm_report_CS65790.sql)

CS65790 - Genetic context: T-DNA http://www.arabidopsis.org/servlets/TairObject?id=6530293244&type=germplasm

http://araport-dev.jcvi.org/stockdw/?q=stock/arabidopsis/thaliana/individual_line/CS65790
###<a name="CS6131"></a>[CS6131](germplasm_report_CS6131.sql)

CS6131- Genetic context: unknown

http://www.arabidopsis.org/servlets/TairObject?id=1005452151&type=germplasm

http://araport-dev.jcvi.org/stockdw/?q=stock/arabidopsis/thaliana/individual_line/CS6131

