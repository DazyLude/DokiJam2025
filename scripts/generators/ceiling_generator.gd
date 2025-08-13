extends TerrainGenerator
class_name CeilingGenerator


const CEILING_HEIGHT := -3000.0;


func generator_function(x: float) -> float:
	return CEILING_HEIGHT;
