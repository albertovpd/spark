# -*- coding: utf-8 -*-

import numpy as np
import pandas as pd
from pyspark.sql import SparkSession, Window
from pyspark.sql.functions import col, pandas_udf, PandasUDFType
from pyspark.sql.types import LongType

if __name__ == "__main__":
    
    spark = SparkSession.builder.getOrCreate()
    sc = spark.sparkContext

    # Enable Arrow-based columnar data transfers
    spark.conf.set("spark.sql.execution.arrow.enabled", "true")

    # Generate a Pandas DataFrame
    pdf = pd.DataFrame(np.random.rand(100, 3))

    # Create a Spark DataFrame from a Pandas DataFrame using Arrow
    df = spark.createDataFrame(pdf)

    # Convert the Spark DataFrame back to a Pandas DataFrame using Arrow
    result_pdf = df.select("*").toPandas()

    # Declare the function and create the UDF
    def multiply_func(a, b):
        return a * b

    multiply = pandas_udf(multiply_func, returnType=LongType())

    # The function for a pandas_udf should be able to execute with local Pandas data
    x = pd.Series([1, 2, 3])
    print(multiply_func(x, x))
    # 0    1
    # 1    4
    # 2    9
    # dtype: int64

    # Create a Spark DataFrame, 'spark' is an existing SparkSession
    df = spark.createDataFrame(pd.DataFrame(x, columns=["x"]))

    # Execute function as a Spark vectorized UDF
    df.select(multiply(col("x"), col("x"))).show()
    # +-------------------+
    # |multiply_func(x, x)|
    # +-------------------+
    # |                  1|
    # |                  4|
    # |                  9|
    # +-------------------+

    df = spark.createDataFrame(
        [(1, 1.0), (1, 2.0), (2, 3.0), (2, 5.0), (2, 10.0)],
        ("id", "v"))

    @pandas_udf("id long, v double", PandasUDFType.GROUPED_MAP)
    def subtract_mean(pdf):
        # pdf is a pandas.DataFrame
        v = pdf.v
        return pdf.assign(v=v - v.mean())

    df.groupby("id").apply(subtract_mean).show()
    # +---+----+
    # | id|   v|
    # +---+----+
    # |  1|-0.5|
    # |  1| 0.5|
    # |  2|-3.0|
    # |  2|-1.0|
    # |  2| 4.0|
    # +---+----+

    df = spark.createDataFrame(
        [(1, 1.0), (1, 2.0), (2, 3.0), (2, 5.0), (2, 10.0)],
        ("id", "v"))

    @pandas_udf("double", PandasUDFType.GROUPED_AGG)
    def mean_udf(v):
        return v.mean()

    df.groupby("id").agg(mean_udf(df['v'])).show()
    # +---+-----------+
    # | id|mean_udf(v)|
    # +---+-----------+
    # |  1|        1.5|
    # |  2|        6.0|
    # +---+-----------+

    w = Window \
        .partitionBy('id') \
        .rowsBetween(Window.unboundedPreceding, Window.unboundedFollowing)
    df.withColumn('mean_v', mean_udf(df['v']).over(w)).show()
    # +---+----+------+
    # | id|   v|mean_v|
    # +---+----+------+
    # |  1| 1.0|   1.5|
    # |  1| 2.0|   1.5|
    # |  2| 3.0|   6.0|
    # |  2| 5.0|   6.0|
    # |  2|10.0|   6.0|
    # +---+----+------+

    spark.stop()
