extends TerrainGenerator
class_name CeilingGenerator


const CEILING_HEIGHT := 1000.0;
var floor_generator : TerrainGenerator = null;


func generator_function(x: float) -> float:
	return floor_generator.generator_function(x) - CEILING_HEIGHT;
