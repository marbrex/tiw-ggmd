# A - Les requêtes SQL

[Voir scripts/requetes.sql](scripts/requetes.sql)

# B - Traitement des requêtes sur grp-XX-small

## Experimentations GGMD1

### Q1
Execution time: 5m 24s  
Planning time: 232ms  
Cout : 5 490 000  
[Plan d'exécution json](plan_execution/small/q1/Q1_small_base_on_personne.json)  
[Plan d'exécution image](plan_execution/small/q1/Q1_small_base_on_personne.png)  
[Statistiques](plan_execution/small/q1/Q1_small_base_on_personne_stats.png)  

### Q2
Execution time: N/A  
Planning time: N/A  
Cout : 13 200 000  
[Plan d'exécution json](plan_execution/small/q2/Q2_small_base_on_personne.json)  
[Plan d'exécution image](plan_execution/small/q2/Q2_small_base_on_personne.png)  
[Statistiques](plan_execution/small/q2/Q2_small_base_on_personne_stats.png)  

Erreur générée:
```log
[53100] ERROR: could not write to file "base/pgsql_tmp/pgsql_tmp19593.1": No space left on device
```

### Q3
Execution time: 6m 16s  
Planning time: 8,4ms  
Cout : 19 300 000  
[Plan d'exécution json](plan_execution/small/q3/Q3_small_base_on_personne.json)  
[Plan d'exécution image](plan_execution/small/q3/Q3_small_base_on_personne.png)  
[Statistiques](plan_execution/small/q3/Q3_small_base_on_personne_stats.png)  

## Expérimentations GGMD1 - Index 

### Q1
Execution time:   
Planning time:   
Cout :  
[Plan d'exécution json](plan_execution/small/q1/Q1_small_index_on_personne.json)  
[Plan d'exécution image](plan_execution/small/q1/Q1_small_index_on_personne.png)  
[Statistiques](plan_execution/small/q1/Q1_small_index_on_personne_stats.png)  

### Q2
Execution time:   
Planning time:   
Cout :  
[Plan d'exécution json](plan_execution/small/q2/Q2_small_index_on_personne.json)  
[Plan d'exécution image](plan_execution/small/q2/Q2_small_index_on_personne.png)  
[Statistiques](plan_execution/small/q2/Q2_small_index_on_personne_stats.png)  

### Q3
Execution time:   
Planning time:   
Cout :  
[Plan d'exécution json](plan_execution/small/q3/Q3_small_index_on_personne.json)  
[Plan d'exécution image](plan_execution/small/q3/Q3_small_index_on_personne.png)  
[Statistiques](plan_execution/small/q3/Q3_small_index_on_personne_stats.png)  

## Expérimentations GGMD1 - configuration 

### Changement de la configuration de la base de données

| parametre | ancienne valeur | nouvelle valeur |
|-|-|-|
| shared_buffers | 128MB | 1024MB |
| effective_cache_size | unsued | 1024MB |
| wal_sync_method |unused | fsync |
| wal_buffers | unused | -1 |
| max_connections | 100 | 10 |
| work_mem | unused | 512MB |
| maintenance_work_mem | unused | 1024MB |
| autovacuum_work_mem | unused | -1 |
| autovacuum | unused | on |
| track_counts | unused | on |

### Q1
Execution time: 8m 17s  
Planning time: 196ms  
Cout : 3 890 000  
[Plan d'exécution json](plan_execution/small/q1/Q1_small_config_opti_on_personne.json)  
[Plan d'exécution image](plan_execution/small/q1/Q1_small_config_opti_on_personne.png)  
[Statistiques](plan_execution/small/q1/Q1_small_config_opti_on_personne_stats.png)  

Le plan d'execution est simplifié et le cout diminué mais le temps d'execution est allongé.

### Q2

Execution time: N/A  
Planning time: N/A  
Cout :  11 500 000  
[Plan d'exécution json](plan_execution/small/q2/Q2_small_config_opti_on_personne.json)  
[Plan d'exécution image](plan_execution/small/q2/Q2_small_config_opti_on_personne.png)  
[Statistiques](plan_execution/small/q2/Q2_small_config_opti_on_personne_stats.png)

Erreur générée:
```log
[57P02] terminating connection because of crash of another server process
```

Le plan d'execution n'est pas modifié et postgreql crash en executant la requête.

### Q3

Execution time: 8m 28s  
Planning time: 2s 323ms  
Cost : 19 300 000  
[Plan d'exécution json](plan_execution/small/q3/Q3_small_config_opti_on_personne.json)  
[Plan d'exécution image](plan_execution/small/q3/Q3_small_config_opti_on_personne.png)  
[Statistiques](plan_execution/small/q3/Q3_small_config_opti_on_personne_stats.png)  

Le plan d'execution n'est pas modifié et le cout est le même mais le temps d'execution ainsi que celui de planification sont allongés.

# C - Traitement des requêtes sur grp-XX-medium

## Expérimentations GGMD1

### Q1
Execution time: 6m 57s  
Planning time: 117ms  
Cout : 5 490 000  
[Plan d'exécution json](plan_execution/medium/q1/Q1_medium_base_on_personne.json)  
[Plan d'exécution image](plan_execution/medium/q1/Q1_medium_base_on_personne.png)  
[Statistiques](plan_execution/medium/q1/Q1_medium_base_on_personne_stats.png)  
