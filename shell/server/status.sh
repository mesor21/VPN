mpstat -P ALL 1 1 | awk '$3 == "all" {print 100 - $13}'
wg