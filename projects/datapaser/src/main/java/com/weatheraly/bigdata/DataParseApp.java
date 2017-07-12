package com.weatheraly.bigdata;

import java.io.File;
import java.net.URL;
import java.net.URLClassLoader;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

import org.apache.avro.Schema;
import org.apache.avro.generic.GenericData;
import org.apache.avro.generic.GenericRecord;
import org.apache.avro.mapred.AvroKey;
import org.apache.avro.mapred.AvroValue;
import org.apache.avro.mapreduce.AvroJob;
import org.apache.avro.mapreduce.AvroKeyOutputFormat;

public class DataParseApp extends Configured implements Tool {

    public static void printClassPath() {
        ClassLoader cl = ClassLoader.getSystemClassLoader();
        URL[] urls = ((URLClassLoader) cl).getURLs();
        System.out.println("classpath BEGIN");
        for (URL url : urls) {
            System.out.println(url.getFile());
        }
        System.out.println("classpath END");
    }

    public static void main(String[] args) throws Exception {
        // DEBUG for classpath
        // printClassPath();
        int res = ToolRunner.run(new Configuration(), new DataParseApp(), args);
        System.exit(res);
    }

    @Override
    public int run(String[] args) throws Exception {
        if (args.length != 2) {
            System.err.println("Usage: DataParseApper <input> <output>");
            return -1;
        }

        Schema schema = new Schema.Parser().parse(
                    getClass().getClassLoader().getResourceAsStream("noaarecord.avsc"));

        Job job = Job.getInstance(getConf());
        job.setJarByClass(DataParseApp.class);
        job.setJobName("Parse Weather Info");

        // 设置输入 (文件夹里面是gz文件)
        FileInputFormat.addInputPath(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));

        AvroJob.setMapOutputKeySchema(job, Schema.create(Schema.Type.STRING));
        AvroJob.setMapOutputValueSchema(job, schema);
        AvroJob.setOutputKeySchema(job, schema);

        job.setInputFormatClass(TextInputFormat.class);
        job.setOutputFormatClass(AvroKeyOutputFormat.class);

        // 设置map/reduder的处理类
        job.setMapperClass(DataParseMapper.class);
        job.setReducerClass(DataParseReducer.class);
        
        // 等待结果
        return job.waitForCompletion(true) ? 0 : 1;
    }
}
