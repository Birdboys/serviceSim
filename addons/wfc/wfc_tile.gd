extends Resource
class_name WFCTile

var tile_type : WFCInfo.tile_type
var rot_val : int
var is_collapsed := false

var all_possibilities : Array[String]

func initPossibilities(p:Array[String]):
	all_possibilities = p.duplicate(true)
	
func collapse():
	if is_collapsed: return
	is_collapsed = true
	all_possibilities = [all_possibilities.pick_random()]
	tile_type = int(all_possibilities[0][0])
	rot_val = int(all_possibilities[0][1])

func collapseWeighted():
	if is_collapsed: return
	is_collapsed = true
	var tile_possibilities = all_possibilities.map(func(t): return int(t[0]))
	var tile_weights = tile_possibilities.map(func(t): return 1.0 if t not in WFCInfo.tile_weights else WFCInfo.tile_weights[t])
	var weight_sum = tile_weights.reduce(func(t, x): return t+x, 0)
	var tile_probs = tile_weights.map(func(w): return w/weight_sum)
	#print(tile_probs)
	var accum = 0.0
	var rand = randf()
	for x in range(len(tile_probs)):
		accum += tile_probs[x]
		if rand <= accum:
			all_possibilities = [all_possibilities[x]]
			tile_type = int(all_possibilities[0][0])
			rot_val = int(all_possibilities[0][1])
			return
	
func constrain(illegal_tile: String):
	all_possibilities.erase(illegal_tile)
	#if len(all_possibilities) == 1: collapse()
	
func getEntropy():
	return len(all_possibilities)

func getShannonEntropy():
	var tile_possibilities = all_possibilities.map(func(t): return int(t[0]))
	var tile_weights = tile_possibilities.map(func(t): return 1.0 if t not in WFCInfo.tile_weights else WFCInfo.tile_weights[t])
	var weight_sum = tile_weights.reduce(func(t, x): return t+x, 0)
	var tile_probs = tile_weights.map(func(w): return w/weight_sum)
	var entropy_val := 0.0
	for x in range(len(tile_weights)):
		entropy_val += tile_probs[x] * (log(tile_probs[x])/log(2))
	#print("DOING ENTROPY \n",tile_possibilities,"\n",tile_weights,"\n",tile_probs,"\n", -entropy_val)
	return -entropy_val
	
