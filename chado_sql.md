# Chado SQL

## Germplasm Information

### [CS65790 SQL](germplasm_report_CS65790.sql)

CS65790 - Genetic context: T-DNA
http://www.arabidopsis.org/servlets/TairObject?id=6530293244&type=germplasm

http://araport-dev.jcvi.org/stockdw/?q=stock/arabidopsis/thaliana/individual_line/CS65790

```
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
```

#### SQL Output

| germplasm_name | germplasm_type  | germplasm_tair_accession_url                                            | germplasm_tair_accession | description                                                                    | taxon                |
|----------------|-----------------|-------------------------------------------------------------------------|--------------------------|--------------------------------------------------------------------------------|----------------------|
| CS65790        | individual_line | http://arabidopsis.org/servlets/TairObject?type=germplasm&id=6530293244 | 6530293244               | confirmed line isolated from original SALK line; homozygous for the insertion. | Arabidopsis thaliana |

## NASC Stock Number

```
select s.name germplasm_name, sn.name nasc_stock_number from stock_synonym stn
join 
synonym sn
on stn.synonym_id = sn.synonym_id
join
stock s
on s.stock_id = stn.stock_id
and s.name = 'CS65790';
```
### SQL Output
| germplasm_name | nasc_stock_number |
|----------------|-------------------|
| CS65790        | N65790            |

## Germplasm Descriptor

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
	s.name = 'CS65790'
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
	s.name = 'CS65790' and cv.name = 'mutagen_type'
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
	s.name = 'CS65790' and cv.name = 'chromosomal_constitution' and cp.name = 'ploidy' 
ORDER BY
	sv.rank;
```
#### SQL Output

| germplasm_name | term_type                | relationship_type | aneploid  | ploidy_property | ploidy_value |
|----------------|--------------------------|-------------------|-----------|-----------------|--------------|
| CS65790        | chromosomal_constitution | is not a          | aneuploid | ploidy          | 2            |

## Pedigree

### Germplasm background accession

```
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

```
#### SQL Output

| type    | background_accession | relationship                 | germplasm_name | germplasm_type  |
|---------|----------------------|------------------------------|----------------|-----------------|
| ecotype | Col-0                | is a background_accession_of | CS65790        | individual_line |


### Parent Lines

```
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
```
#### SQL Output
| stock_relationship_id | germplasm_type  | germplasm_name | relationship      | parent_line |
|-----------------------|-----------------|----------------|-------------------|-------------|
| 1                     | individual_line | CS65790        | is a offspring_of | SALK_142526 |

## Genetic Context
### Locus and allele feature accociated with the germplasm 

```
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
```

#### SQL Output

| locus     | allele | germplasm_name |
|-----------|--------|----------------|
| AT1G51680 | 4CL1-1 | CS65790        |
