package com.weatheraly.bigdata;

import java.io.IOException;

import org.apache.avro.Schema;
import org.apache.avro.generic.GenericData;
import org.apache.avro.generic.GenericRecord;
import org.apache.avro.mapred.AvroValue;
import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.io.ImmutableBytesWritable;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DataParseReducer
    extends Reducer<Text, AvroValue<GenericRecord>, ImmutableBytesWritable, Put> {

    private static Logger logger = LoggerFactory.getLogger(DataParseReducer.class);
    Schema schema = null;
    GenericRecord record = null;

    @Override
    protected void setup(Context context) 
        throws IOException, InterruptedException {
        try {
            schema = new Schema.Parser().parse(
                    getClass().getClassLoader().getResourceAsStream("noaarecord.avsc"));
            record = new GenericData.Record(schema);
            // 初始化默认最小值
            record.put("observationTime", "0000");
            record.put("directionAngle", -1);
            record.put("windSpeedRate", -1);
            record.put("skyHeightDimension", -1);
            record.put("skyDistanceDimension", -1);
            record.put("airTemperature", -99);
        } catch(IOException e){
            logger.info("fixme " + e);
        }
    }

    @Override
    public void reduce(Text key, Iterable<AvroValue<GenericRecord>> values, Context context)
        throws IOException, InterruptedException {
        for (AvroValue<GenericRecord> value : values) {
            GenericRecord r = value.datum();
            if ((Integer)record.get("directionAngle") < (Integer) r.get("directionAngle"))
                record.put("directionAngle", r.get("directionAngle"));

            if ((Integer)record.get("windSpeedRate") < (Integer) r.get("windSpeedRate"))
                record.put("windSpeedRate", r.get("windSpeedRate"));

            if ((Integer)record.get("skyHeightDimension") < (Integer) r.get("skyHeightDimension"))
                record.put("skyHeightDimension", r.get("skyHeightDimension"));
            
            if ((Integer)record.get("skyDistanceDimension") < (Integer) r.get("skyDistanceDimension"))
                record.put("skyDistanceDimension", r.get("skyDistanceDimension"));

            if ((Integer)record.get("airTemperature") < (Integer) r.get("airTemperature"))
                record.put("airTemperature", r.get("airTemperature"));
        }
        logger.info("reduce: " + record.toString());
        // 注释掉, 改为HBase存储
        // context.write(new AvroKey<GenericRecord>(record), NullWritable.get());
        
        Put put = new Put(key.toString().getBytes());
        put.addColumn(Bytes.toBytes("content"), Bytes.toBytes("dira"), Bytes.toBytes((Integer)record.get("directionAngle")));
        put.addColumn(Bytes.toBytes("content"), Bytes.toBytes("winr"), Bytes.toBytes((Integer)record.get("windSpeedRate")));
        put.addColumn(Bytes.toBytes("content"), Bytes.toBytes("skyh"), Bytes.toBytes((Integer)record.get("skyHeightDimension")));
        put.addColumn(Bytes.toBytes("content"), Bytes.toBytes("skyd"), Bytes.toBytes((Integer)record.get("skyDistanceDimension")));
        put.addColumn(Bytes.toBytes("content"), Bytes.toBytes("airt"), Bytes.toBytes((Integer)record.get("airTemperature")));
        context.write(new ImmutableBytesWritable(key.toString().getBytes()), put);
    }
}
