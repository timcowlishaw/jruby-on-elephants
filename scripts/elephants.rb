$: << File.join(File.dirname(__FILE__), "..", "lib")
["/usr/local/hadoop/hadoop-core-0.20.205.0.jar","/usr/local/mahout/lib/mahout-collections-1.0.jar","/usr/local/mahout/lib/guava-r03.jar","/usr/local/mahout/mahout-core-0.5.jar","/usr/local/mahout/mahout-math-0.5.jar","/usr/local/lucene/lucene-core-3.4.0.jar"].each {|p| require p }
require 'elephants'
Elephants.run
