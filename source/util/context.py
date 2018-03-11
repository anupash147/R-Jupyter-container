from __future__ import print_function

try:
    import findspark

    findspark.init()
    import pyspark

    sc = pyspark.SparkContext()
    sc.setLogLevel('WARN')
    print("spark context created")

    from pyspark import SparkConf, SparkContext, HiveContext
    from pyspark.sql import SQLContext

    sqlc = SQLContext(sc)
    sqlh = HiveContext(sc)
    sqlh.setConf("spark.sql.parquet.compression.codec.", "gzip")

except:
    print("spark context exists")
