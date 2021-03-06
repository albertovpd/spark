# -*- coding: utf-8 -*-

import numpy as np
import pandas as pd

from pyspark.sql import SparkSession, Window
from pyspark.sql.functions import col, pandas_udf
from pyspark.sql.types import LongType
from typing import Iterator, Tuple

if __name__ == "__main__":
    
    spark = SparkSession.builder.getOrCreate()
    sc = spark.sparkContext

    # Enable Arrow-based columnar data transfers
    spark.conf.set("spark.sql.execution.arrow.pyspark.enabled", "true")

    # Generate a Pandas DataFrame
    pdf = pd.DataFrame(np.random.rand(100, 3))

    # Create a Spark DataFrame from a Pandas DataFrame using Arrow
    df = spark.createDataFrame(pdf)

    # Convert the Spark DataFrame back to a Pandas DataFrame using Arrow
    result_pdf = df.select("*").toPandas()

    @pandas_udf("col1 string, col2 long")
    def func(s1: pd.Series, s2: pd.Series, s3: pd.DataFrame) -> pd.DataFrame:
        s3['col2'] = s1 + s2.str.len()
        return s3

    # Create a Spark DataFrame that has three columns including a sturct column.
    df = spark.createDataFrame(
        [[1, "a string", ("a nested string",)]],
        "long_col long, string_col string, struct_col struct<col1:string>")

    df.printSchema()
    # root
    # |-- long_column: long (nullable = true)
    # |-- string_column: string (nullable = true)
    # |-- struct_column: struct (nullable = true)
    # |    |-- col1: string (nullable = true)

    df.select(func("long_col", "string_col", "struct_col")).printSchema()
    # |-- func(long_col, string_col, struct_col): struct (nullable = true)
    # |    |-- col1: string (nullable = true)
    # |    |-- col2: long (nullable = true)

    # Declare the function and create the UDF
    def multiply_func(a: pd.Series, b: pd.Series) -> pd.Series:
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

    pdf = pd.DataFrame([1, 2, 3], columns=["x"])
    df = spark.createDataFrame(pdf)

    # Declare the function and create the UDF
    @pandas_udf("long")
    def plus_one(iterator: Iterator[pd.Series]) -> Iterator[pd.Series]:
        for x in iterator:
            yield x + 1

    df.select(plus_one("x")).show()
    # +-----------+
    # |plus_one(x)|
    # +-----------+
    # |          2|
    # |          3|
    # |          4|
    # +-----------+

    pdf = pd.DataFrame([1, 2, 3], columns=["x"])
    df = spark.createDataFrame(pdf)

    # Declare the function and create the UDF
    @pandas_udf("long")
    def multiply_two_cols(
            iterator: Iterator[Tuple[pd.Series, pd.Series]]) -> Iterator[pd.Series]:
        for a, b in iterator:
            yield a * b

    df.select(multiply_two_cols("x", "x")).show()
    # +-----------------------+
    # |multiply_two_cols(x, x)|
    # +-----------------------+
    # |                      1|
    # |                      4|
    # |                      9|
    # +-----------------------+



    df = spark.createDataFrame(
        [(1, 1.0), (1, 2.0), (2, 3.0), (2, 5.0), (2, 10.0)],
        ("id", "v"))

    # Declare the function and create the UDF
    @pandas_udf("double")
    def mean_udf(v: pd.Series) -> float:
        return v.mean()

    df.select(mean_udf(df['v'])).show()
    # +-----------+
    # |mean_udf(v)|
    # +-----------+
    # |        4.2|
    # +-----------+

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
