package com.weatheraly.bigdata;

import java.io.IOException;

import org.apache.avro.Schema;
import org.apache.avro.generic.GenericData;
import org.apache.avro.generic.GenericRecord;
import org.apache.avro.mapred.AvroValue;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DataParseMapper extends Mapper<LongWritable, Text, Text, AvroValue<GenericRecord>> {

    private static Logger logger = LoggerFactory.getLogger(DataParseMapper.class);
    private NoaaParser noaa = new NoaaParser();

    Schema schema = null;
    GenericRecord record = null;

    @Override
    protected void setup(Context context) 
        throws IOException, InterruptedException {
        try {
            
            schema = new Schema.Parser().parse(
                    getClass().getClassLoader().getResourceAsStream("noaarecord.avsc"));
            record = new GenericData.Record(schema);
        } catch(IOException e){
            logger.info("fixme " + e);
        }
    }

    @Override
    public void map(LongWritable key, Text value, Context context)
        throws IOException, InterruptedException {
        noaa.parse(value.toString());
        String keyID = noaa.getStationId() + "-" + noaa.getDate();
        record.put("observationTime", noaa.getTime());
        if (noaa.isValid(NoaaParser.DIRECTION_ANGLE))
            record.put("directionAngle", noaa.getDirectionAngle());
        else 
            record.put("directionAngle", -1);

        if (noaa.isValid(NoaaParser.WIND_SPEED_RATE))
            record.put("windSpeedRate", noaa.getWindSpeedRate());
        else
            record.put("windSpeedRate", -1);

        if (noaa.isValid(NoaaParser.SKY_HEIGHT_DIM))
            record.put("skyHeightDimension", noaa.getSkyHeightDimension());
        else 
            record.put("skyHeightDimension", -1);

        if (noaa.isValid(NoaaParser.SKY_DISTANCE_DIM))
            record.put("skyDistanceDimension", noaa.getSkyDistanceDimension());
        else 
            record.put("skyDistanceDimension", -1);

        if (noaa.isValid(NoaaParser.AIR_TEMPERATURE))
            record.put("airTemperature", noaa.getAirTemperature());
        else
            record.put("airTemperature", -99);
        logger.info("map: " + record.toString());
        context.write(new Text(keyID), new AvroValue<GenericRecord>(record));
    }
}
