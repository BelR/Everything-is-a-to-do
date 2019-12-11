module Z_auxiliaresBRW
#-------------------#

using HDF5
function brw_things( file_brw::String ) # depende de brw file
	brw = h5open( file_brw, "r" );
	# channels and coords for each one
	Chs = read( brw[ "/3BRecInfo/3BMeaStreams/RawRanges" ] )[ "Chs" ]; 
	x = zeros( Int, size( Chs, 1 ), 3 );
	for i = 1:size( Chs, 1 )
	   x[ i, : ] = [ i, Chs[ i ].data[ 1 ], Chs[ i ].data[ 2 ] ]; # Channels, [number coord1 coord2]
	end  

	ValidChs = read( brw[ "/3BData/3BInfo/3BNoise/ValidChs" ] ); # Valid Channels (software desition)
	y = zeros( Int, size( ValidChs, 1 ), 3 );
	for i = 1:size( ValidChs, 1 )
	   y[i,:] = [ ( ( ValidChs[ i ].data[ 1 ] - 1)*64 + ValidChs[ i ].data[ 2 ] ), ValidChs[ i ].data[ 1 ], ValidChs[ i ].data[ 2 ] ];# Valid Channels, [number coord1 coord2]
	end
	
	RawEncodedTOC = read( brw[ "/3BData/RawEncodedTOC" ] )[ 2 ]; # numero real de frames registrados
	RecVars = read( brw[ "/3BRecInfo/3BRecVars" ] );
    Offset = RecVars[ "SignalInversion" ][ ]*RecVars[ "MinVolt" ][ ];
    Factor = RecVars[ "SignalInversion" ][ ]*( RecVars[ "MaxVolt" ][ ] - RecVars[ "MinVolt" ][ ] )/( 2^RecVars[ "BitDepth" ][ ] );
    NRecFrames = RecVars[ "NRecFrames" ][ ]; # numero propuesto de cuadros registrados
    SamplingRate = RecVars[ "SamplingRate" ][ ];
    dset = brw[ "3BData/RawEncoded" ];
  
	vars = Dict(
        "Offset"        => Offset,
        "Factor"        => Factor,
        "NRecFrames"    => NRecFrames,
        "SamplingRate"  => SamplingRate,
        "Chs"   	    => x,
		"ValidChs" 	    => y,
        "RawEncodedTOC" => RawEncodedTOC,
        "dset"          => dset,
        "MaxVolt"       => RecVars[ "MaxVolt" ][ ],
        "MinVolt"       => RecVars[ "MinVolt" ][ ]
        
    );

    return vars
    
end

#----#
export brw_things

#-#
end
