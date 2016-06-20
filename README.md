influxdb-r
==========

R library for InfluxDB. Currently only supports querying.

Install using devtools:

```
> if (!require(devtools))
    install.packages('devtools')
> devtools::install_github('influxdb-r', 'influxdb')
```

Example usage:

```
> library(influxdb)
> results <- influxdb_query('127.0.0.1', 8086, 'mydb', 'user', 'password', 'SELECT * FROM testing')
$some_series
        time sequence_number             email state value
1 1386405189          802637       foo@bar.com    CO 191.3
2 1386405182          802636 paul@influxdb.org    NY    23

$some_series2
        time sequence_number        email state value
1 1386405625          802640 baz@quux.com    MA    63
> summary(results$some_series$value)
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
  23.00   65.08  107.20  107.20  149.20  191.30 
```
