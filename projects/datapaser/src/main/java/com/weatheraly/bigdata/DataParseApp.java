package com.weatheraly.bigdata;

import java.io.IOException;
import java.net.URL;
import java.net.URLClassLoader;

import org.apache.avro.Schema;
import org.apache.avro.mapreduce.AvroJob;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.hbase.HConstants;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.HColumnDescriptor;
import org.apache.hadoop.hbase.HTableDescriptor;
import org.apache.hadoop.hbase.TableName;
import org.apache.hadoop.hbase.client.Admin;
import org.apache.hadoop.hbase.client.Connection;
import org.apache.hadoop.hbase.client.ConnectionFactory;
import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.io.ImmutableBytesWritable;
import org.apache.hadoop.hbase.mapreduce.TableOutputFormat;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DataParseApp extends Configured implements Tool {

    private static Logger logger = LoggerFactory.getLogger(DataParseApp.class);

    /**
     *  调试使用, 打印出应用程序加载的classpath
     *
     */
    public static void printClassPath() {
        ClassLoader cl = ClassLoader.getSystemClassLoader();
        URL[] urls = ((URLClassLoader) cl).getURLs();
        System.out.println("classpath BEGIN");
        for (URL url : urls) {
            System.out.println(url.getFile());
        }
        System.out.println("classpath END");
    }

    
    /**
     * 创建HBase表 
     * 
     * @param tablename 存放天气数据的表名
     *
     * @throws IOException
     */
    public static void createHBaseTable(String tablename) throws IOException {   
        Configuration config = HBaseConfiguration.create();
        logger.info("Config files = " + config.toString());
        logger.info("Get zookeeper.znode.parent = " + 
                config.get(HConstants.ZOOKEEPER_ZNODE_PARENT , HConstants.DEFAULT_ZOOKEEPER_ZNODE_PARENT));
        final String[] serverHosts =                                              
            config.getStrings(HConstants.ZOOKEEPER_QUORUM, HConstants.LOCALHOST);   
        for (int i = 0; i < serverHosts.length; ++i) { 
            logger.info("ZK[" + i + "]: " + serverHosts[i]);
        }
        
        Connection connection = ConnectionFactory.createConnection(config);
        try {
            // Create table
            Admin admin = connection.getAdmin();
            try {
                TableName tableName = TableName.valueOf(tablename);
                // 表名
                HTableDescriptor htd = new HTableDescriptor(tableName);
                // 列族
                HColumnDescriptor hcd = new HColumnDescriptor("content");
                // 表中增加列族
                htd.addFamily(hcd);
                if (admin.tableExists(tableName)) {
                    System.out.println("TableName " + tableName + " exists");
                    admin.disableTable(tableName);
                    // 清空表中数据
                    admin.truncateTable(tableName, false);
                    admin.enableTable(tableName);
                } else 
                    admin.createTable(htd);
            } finally {
                admin.close();
            }
        } finally {
            connection.close();
        }
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
            System.err.println("Usage: DataParseApper <input> <tablename>");
            return -1;
        }

        Schema schema = new Schema.Parser().parse(
                    getClass().getClassLoader().getResourceAsStream("noaarecord.avsc"));

        logger.info("Create HBase table");
        createHBaseTable(args[1]);

        logger.info("Set job property");
        Job job = Job.getInstance(getConf());
        job.setJarByClass(DataParseApp.class);
        job.setJobName("Parse Weather Info");

        // 设置输入 (文件夹里面是gz文件)
        FileInputFormat.addInputPath(job, new Path(args[0]));
        // FileOutputFormat.setOutputPath(job, new Path(args[1]));
        job.getConfiguration().set(TableOutputFormat.OUTPUT_TABLE, args[1]);

        job.setInputFormatClass(TextInputFormat.class);
        // job.setOutputFormatClass(AvroKeyOutputFormat.class);
        job.setOutputFormatClass(TableOutputFormat.class);

        // 设置map/reduder的处理类
        job.setMapperClass(DataParseMapper.class);
        job.setReducerClass(DataParseReducer.class);

        // AvroJob.setMapOutputKeySchema(job, Schema.create(Schema.Type.STRING));
        // AvroJob.setMapOutputValueSchema(job, schema);
        // AvroJob.setOutputKeySchema(job, schema);
        
        // map 输出
        job.setMapOutputKeyClass(Text.class);
        AvroJob.setMapOutputValueSchema(job, schema);
        // reduce 输出
        job.setOutputKeyClass(ImmutableBytesWritable.class);
        job.setOutputValueClass(Put.class);
        
        // 等待结果
        logger.info("Wait for result");
        return job.waitForCompletion(true) ? 0 : 1;
    }
}
