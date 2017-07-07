package com.weatheraly.bigdata;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

public class DataParseApp extends Configured implements Tool {

    public static void main(String[] args) throws Exception {
        int res = ToolRunner.run(new Configuration(), new DataParseApp(), args);
        System.exit(res);
    }

    @Override
    public int run(String[] args) throws Exception {
        if (args.length != 2) {
            System.err.println("Usage: DataParseApper <input> <output>");
            return -1;
        }

        Job job = Job.getInstance(getConf());
        job.setJarByClass(DataParseApp.class);
        job.setJobName("Parse Weather Info");

        // 设置输入 (文件夹里面是gz文件)
        FileInputFormat.addInputPath(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));

        // 设置map/reduder的处理类
        job.setMapperClass(DataParseMapper.class);
        job.setReducerClass(DataParseReducer.class);

        // 设置map函数输出类型, 如果不设置就和reduce一致
        // job.setMapOutputKeyClass(xx);
        // job.setMapOutputValueClass(xx);

        // 设置reduce函数输出类型
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);

        // 等待结果
        return job.waitForCompletion(true) ? 0 : 1;
    }
}
