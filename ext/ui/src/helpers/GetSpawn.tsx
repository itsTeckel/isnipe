import Delaunator from 'delaunator';
const FAR_DISTANCE = 60;//If we found a spawn further than this. Exit early

export function GetSpawn(points: Array<number[]>, map: string): [number, any] {
  var spawnPoints = Spawns[map];
  if(spawnPoints == null){
    dispatchVenice([0, null]);
    return [0, null];
  }
  //If points is empty or invalid. Pick a random spawn point.
  if (points == null || points[0] == null || points.length == 0) {
    let keys = Object.keys(spawnPoints);
    let spawnPoint = spawnPoints[keys[Math.floor(Math.random() * keys.length)]];
    let result: [number, any] = [1337, spawnPoint];
    dispatchVenice(result);
    return result;
  }
  let result = CalculateSpawn(points, spawnPoints);
  dispatchVenice(result)
  return result;
}

function dispatchVenice(result: any) {
  if (navigator.userAgent.includes('VeniceUnleashed')) {
    var json = JSON.stringify(result);
    console.log(json);
    WebUI.Call('DispatchEventLocal', 'WebUICalculatedSpawn', json);
  }
}

export function CalculateSpawn(points: Array<number[]>, spawns: any): [number, any] {
  //For each spawn find the farthest point
  var best: [number, any] = [0, null];
  spawns = shuffle(spawns);

  for (let i = 0; i < spawns.length; i++) {
    let spawn = spawns[i];
    let result = spawnDistance(points, spawn);

    //If this result is better than what we found before, take it.
    if(result[0] > best[0]) {
      best = result
    }

    //Exit early if we found a spawnpoint that is far away.
    if(best[0] >= FAR_DISTANCE){
      break;
    }
  }
  return best;
}

function spawnDistance(points: Array<number[]>, spawn: any): [number, any] {
  if(spawn != null && spawn[3] != null && spawn[3][0] != null) {
    let spawnPoint = spawn[3];

    let distance = closestDistance(points, [spawnPoint[0], spawnPoint[1]]);
    return [distance, spawn];
  }
  return [0, null];
}

function closestDistance(points: Array<number[]>, comparePoint: number[]): number {
  var result = -1;
  for (let i = 0; i < points.length; i++) {
    let point = points[i];
    let distance = mathDist(point[0]!, point[1]!, point[2]!, comparePoint[0]!, comparePoint[1]!, comparePoint[2]!);
    if(result == -1 || distance < result) {
      result = distance;
    }
    if(result <= 10) {
      return result;
    }
  }
  return result;
}

function mathDist(x1:number,y1:number,z1:number,x2:number,y2:number,z2:number): number{ 
  if(!x2) x2=0; 
  if(!y2) y2=0;
  if(!z2) z2=0;
  return Math.sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1)+(z2-z1)*(z2-z1)); 
}

function test() {
  var a = [4, 3, 0];
  var b = [2, 1, 0];
  var c = [0, 0, 0];
  var d = [1, 3, 0];

  var points = [a, b, c, d];
  var spawns = {
     1: {"interesting": 121},
     2: {"interesting": 13}
  }
  console.log(CalculateSpawn(points, spawns));
  //CalculateSpawn([[4, 3], [2, 1], [0, 0], [1, 3]], {1: 123, 2: 111})
  /*GetSpawn([[1.7299436330795,6.3953123092651, 0],[-9.143627166748,6.3953123092651, 0],[44.114418029785,1.9418169260025, 0],[-19.381170272827,6.3953123092651,0],[43.642139434814,2.2906849384308,0]], "XP2_Palace");
  should output:
0: 17.507361299547927
1: Array(4)
0: (3) [0.74616569280624, 0, 0.66576027870178]
1: (3) [0, 1, 0]
2: (3) [-0.66576027870178, 0, 0.74616569280624]
3: (3) [19.2373046875, 6.3923826217651, 18.822265625]
*/
}

function shuffle(input: any) {
  for (let i = input.length - 1; i >= 0; i--) {
    let randomIndex = Math.floor(Math.random() * (i + 1));
    let itemAtIndex = input[randomIndex];
    input[randomIndex] = input[i];
    input[i] = itemAtIndex;
  }
  return input;
}

var Spawns: any = {
      //Ziba Tower
      "XP2_Skybar": [
            [[0.87985253334045, 0.0, 0.47524675726891], [0.0, 1.0, 0.0], [-0.47524675726891, 0.0, 0.87985253334045], [38.025390625, 10.241094589233, -15.9267578125]],
            [[0.78991669416428, 0.0, -0.61321413516998], [0.0, 1.0, 0.0], [0.61321413516998, 0.0, 0.78991669416428], [-48.6953125, 11.246883392334, -10.76171875]],
            [[-0.83816993236542, 0.0, -0.54540914297104], [0.0, 1.0, 0.0], [0.54540914297104, 0.0, -0.83816993236542], [-48.541954040527, 11.239187240601, 4.4875049591064]],
            [[0.095165222883224, 0.0, 0.99546146392822], [0.0, 1.0, 0.0], [-0.99546146392822, 0.0, 0.095165222883224], [-31.517683029175, 10.879703521729, -3.7763655185699]],
            [[-0.61948239803314, 0.0, -0.78501051664352], [0.0, 1.0, 0.0], [0.78501051664352, 0.0, -0.61948239803314], [-27.065433502197, 11.501758575439, -7.8710980415344]],
            [[-0.17415051162243, 0.0, 0.98471903800964], [0.0, 1.0, 0.0], [-0.98471903800964, 0.0, -0.17415051162243], [-20.4873046875, 10.880663871765, -17.7412109375]],
            [[-0.11069636046886, 0.0, 0.9938542842865], [0.0, 1.0, 0.0], [-0.9938542842865, 0.0, -0.11069636046886], [-12.41796875, 10.879696846008, -31.33984375]],
            [[-0.010918388143182, 0.0, -0.99994039535522], [0.0, 1.0, 0.0], [0.99994039535522, 0.0, -0.010918388143182], [-0.0087890625, 10.879710197449, -9.197265625]],
            [[-0.6379634141922, 0.0, -0.77006667852402], [0.0, 1.0, 0.0], [0.77006667852402, 0.0, -0.6379634141922], [11.037136077881, 10.881640434265, 4.833984375]],
            [[0.81157916784286, 0.0, 0.58424246311188], [0.0, 1.0, 0.0], [-0.58424246311188, 0.0, 0.81157916784286], [28.3232421875, 10.880663871765, -25.6728515625]],
            [[-0.85697388648987, 0.0, 0.51535987854004], [0.0, 1.0, 0.0], [-0.51535987854004, 0.0, -0.85697388648987], [27.208984375, 10.880663871765, -17.0419921875]],
            [[-0.21219703555107, 0.0, 0.97722691297531], [0.0, 1.0, 0.0], [-0.97722691297531, 0.0, -0.21219703555107], [30.6611328125, 15.366015434265, -26.23828125]],
            [[0.4855922460556, 0.0, -0.8741854429245], [0.0, 1.0, 0.0], [0.8741854429245, 0.0, 0.4855922460556], [1.021484375, 15.360156059265, -29.12109375]],
            [[-0.62509846687317, 0.0, -0.78054589033127], [0.0, 1.0, 0.0], [0.78054589033127, 0.0, -0.62509846687317], [1.4619140625, 15.360156059265, -23.353515625]],
            [[-0.17643634974957, 0.0, -0.98431205749512], [0.0, 1.0, 0.0], [0.98431205749512, 0.0, -0.17643634974957], [0.3908716738224, 15.360156059265, -12.30859375]],
            [[0.64443415403366, 0.0, -0.76465982198715], [0.0, 1.0, 0.0], [0.76465982198715, 0.0, 0.64443415403366], [1.8642578125, 15.360156059265, -16.6279296875]],
            [[0.53501039743423, 0.0, 0.84484547376633], [0.0, 1.0, 0.0], [-0.84484547376633, 0.0, 0.53501039743423], [19.353515625, 15.387499809265, -17.072265625]],
            [[0.66533434391022, 0.0, 0.74654549360275], [0.0, 1.0, 0.0], [-0.74654549360275, 0.0, 0.66533434391022], [20.6611328125, 15.360156059265, -31.69140625]],
            [[-0.1281678378582, 0.0, 0.99175250530243], [0.0, 1.0, 0.0], [-0.99175250530243, 0.0, -0.1281678378582], [-23.3349609375, 15.363085746765, -18.0546875]],
            [[-0.22346246242523, 0.0, 0.97471255064011], [0.0, 1.0, 0.0], [-0.97471255064011, 0.0, -0.22346246242523], [-23.033479690552, 15.363085746765, -14.92857837677]],
            [[0.88780897855759, 0.0, 0.46021217107773], [0.0, 1.0, 0.0], [-0.46021217107773, 0.0, 0.88780897855759], [-30.6328125, 15.360156059265, -19.146484375]],
            [[-0.48135474324226, 0.0, -0.87652587890625], [0.0, 1.0, 0.0], [0.87652587890625, 0.0, -0.48135474324226], [-48.5849609375, 15.364062309265, 6.333984375]],
            [[0.98731464147568, 0.0, 0.15877597033978], [0.0, 1.0, 0.0], [-0.15877597033978, 0.0, 0.98731464147568], [-22.7802734375, 15.360156059265, 5.5751953125]],
            [[-0.99979048967361, 0.0, -0.020467609167099], [0.0, 1.0, 0.0], [0.020467609167099, 0.0, -0.99979048967361], [-20.765625, 15.361132621765, 19.1865234375]]
      ],
    //Noshahr Canals
    "MP_017": [
      [[-0.70174860954285, 0.0, -0.71242469549179], [0.0, 1.0, 0.0], [0.71242469549179, 0.0, -0.70174860954285], [-312.0458984375, 70.536911010742, 323.078125]],
      [[0.62152969837189, 0.0, 0.78339064121246], [0.0, 1.0, 0.0], [-0.78339064121246, 0.0, 0.62152969837189], [-327.2529296875, 70.513534545898, 310.1025390625]],
      [[0.70339822769165, 0.0, -0.7107959985733], [0.0, 1.0, 0.0], [0.7107959985733, 0.0, 0.70339822769165], [-356.7861328125, 67.936325073242, 318.5791015625]],
      [[-0.74390780925751, 0.0, 0.66828221082687], [0.0, 1.0, 0.0], [-0.66828221082687, 0.0, -0.74390780925751], [-362.439453125, 67.945114135742, 312.767578125]],
      [[0.32713311910629, 0.0, -0.9449782371521], [0.0, 1.0, 0.0], [0.9449782371521, 0.0, 0.32713311910629], [-346.7919921875, 71.388473510742, 295.7255859375]],
      [[-0.29239249229431, 0.0, 0.95629841089249], [0.0, 1.0, 0.0], [-0.95629841089249, 0.0, -0.29239249229431], [-336.0263671875, 71.388473510742, 299.375]],
      [[-0.34207788109779, 0.0, -0.93967163562775], [0.0, 1.0, 0.0], [0.93967163562775, 0.0, -0.34207788109779], [-344.6474609375, 70.434371948242, 265.3115234375]],
      [[-0.88363611698151, 0.0, 0.46817430853844], [0.0, 1.0, 0.0], [-0.46817430853844, 0.0, -0.88363611698151], [-331.1875, 70.433418273926, 253.984375]],
      [[0.040696356445551, 0.0, -0.99917155504227], [0.0, 1.0, 0.0], [0.99917155504227, 0.0, 0.040696356445551], [-299.76953125, 70.440231323242, 292.9697265625]],
      [[0.29355686903, 0.0, -0.95594161748886], [0.0, 1.0, 0.0], [0.95594161748886, 0.0, 0.29355686903], [-289.2548828125, 71.374801635742, 280.646484375]],
      [[-0.99980729818344, 0.0, -0.019631166011095], [0.0, 1.0, 0.0], [0.019631166011095, 0.0, -0.99980729818344], [-292.33984375, 66.660934448242, 262.771484375]],
      [[-0.59251260757446, 0.0, -0.80556118488312], [0.0, 1.0, 0.0], [0.80556118488312, 0.0, -0.59251260757446], [-329.630859375, 70.438278198242, 237.5625]],
      [[0.91309833526611, 0.0, -0.40773946046829], [0.0, 1.0, 0.0], [0.40773946046829, 0.0, 0.91309833526611], [-309.2177734375, 70.431442260742, 210.986328125]],
      [[0.58692914247513, 0.0, -0.80963832139969], [0.0, 1.0, 0.0], [0.80963832139969, 0.0, 0.58692914247513], [-328.8818359375, 70.438278198242, 198.5048828125]],
      [[0.74307304620743, 0.0, -0.66921031475067], [0.0, 1.0, 0.0], [0.66921031475067, 0.0, 0.74307304620743], [-353.9228515625, 74.439254760742, 189.8427734375]],
      [[0.69834744930267, 0.0, -0.71575891971588], [0.0, 1.0, 0.0], [0.71575891971588, 0.0, 0.69834744930267], [-358.8486328125, 70.434371948242, 282.0263671875]]
    ],
    //Seine
    "MP_011": [
      [[0.87258917093277, 0.0, 0.48845484852791], [0.0, 1.0, 0.0], [-0.48845484852791, 0.0, 0.87258917093277], [-69.055694580078, 1.2429687976837, 63.549835205078]],
      [[0.4574456512928, 0.0, -0.88923758268356], [0.0, 1.0, 0.0], [0.88923758268356, 0.0, 0.4574456512928], [-99.833984375, 1.2810547351837, 58.1982421875]],
      [[-0.92395204305649, 0.0, -0.38250830769539], [0.0, 1.0, 0.0], [0.38250830769539, 0.0, -0.92395204305649], [-14.564453125, -6.4093751907349, 46.6767578125]],
      [[-0.62932825088501, 0.0, 0.77713960409164], [0.0, 1.0, 0.0], [-0.77713960409164, 0.0, -0.62932825088501], [34.400390625, 1.3484375476837, 70.302734375]],
      [[-0.7307755947113, 0.0, 0.68261778354645], [0.0, 1.0, 0.0], [-0.68261778354645, 0.0, -0.7307755947113], [65.615234375, 1.2800781726837, 61.57421875]],
      [[0.89034533500671, 0.0, -0.45528587698936], [0.0, 1.0, 0.0], [0.45528587698936, 0.0, 0.89034533500671], [67.3076171875, 1.4373368024826, 85.7724609375]],
      [[-0.64422154426575, 0.0, -0.7648389339447], [0.0, 1.0, 0.0], [0.7648389339447, 0.0, -0.64422154426575], [63.9619140625, 3.5203125476837, 119.8427734375]],
      [[0.52052044868469, 0.0, 0.85384917259216], [0.0, 1.0, 0.0], [-0.85384917259216, 0.0, 0.52052044868469], [74.8837890625, 10.403124809265, 137.7177734375]],
      [[0.96356296539307, 0.0, 0.26748168468475], [0.0, 1.0, 0.0], [-0.26748168468475, 0.0, 0.96356296539307], [56.2060546875, 15.381640434265, 147.1962890625]],
      [[0.9482125043869, 0.0, 0.31763672828674], [0.0, 1.0, 0.0], [-0.31763672828674, 0.0, 0.9482125043869], [56.0537109375, 19.200977325439, 147.5]],
      [[0.23395593464375, 0.0, -0.97224718332291], [0.0, 1.0, 0.0], [0.97224718332291, 0.0, 0.23395593464375], [49.35546875, 15.380663871765, 137.814453125]],
      [[0.20052416622639, 0.0, 0.97968876361847], [0.0, 1.0, 0.0], [-0.97968876361847, 0.0, 0.20052416622639], [42.83670425415, 6.478343963623, 129.11039733887]],
      [[0.50875425338745, 0.0, -0.86091178655624], [0.0, 1.0, 0.0], [0.86091178655624, 0.0, 0.50875425338745], [11.904296875, 6.4001951217651, 117.0361328125]],
      [[0.87790411710739, 0.0, 0.47883641719818], [0.0, 1.0, 0.0], [-0.47883641719818, 0.0, 0.87790411710739], [22.1328125, 9.2820310592651, 140.396484375]],
      [[0.60144609212875, 0.0, 0.79891341924667], [0.0, 1.0, 0.0], [-0.79891341924667, 0.0, 0.60144609212875], [16.419921875, 13.140429496765, 131.8388671875]],
      [[-0.92916226387024, 0.0, 0.36967206001282], [0.0, 1.0, 0.0], [-0.36967206001282, 0.0, -0.92916226387024], [21.9853515625, 16.970508575439, 148.138671875]],
      [[-0.70263749361038, 0.0, 0.71154797077179], [0.0, 1.0, 0.0], [-0.71154797077179, 0.0, -0.70263749361038], [-1.4638671875, 8.6414060592651, 182.2666015625]],
      [[-0.81352573633194, 0.0, -0.58152890205383], [0.0, 1.0, 0.0], [0.58152890205383, 0.0, -0.81352573633194], [-25.541015625, 9.9226560592651, 175.0458984375]],
      [[0.85704052448273, 0.0, -0.5152490735054], [0.0, 1.0, 0.0], [0.5152490735054, 0.0, 0.85704052448273], [-25.96875, 13.777300834656, 167.091796875]],
      [[-0.84256792068481, 0.0, 0.53859013319016], [0.0, 1.0, 0.0], [-0.53859013319016, 0.0, -0.84256792068481], [-40.128929138184, 1.2280070781708, 121.07224273682]],
      [[-0.90100461244583, 0.0, 0.43380948901176], [0.0, 1.0, 0.0], [-0.43380948901176, 0.0, -0.90100461244583], [-59.3876953125, 1.4363766908646, 121.814453125]],
      [[-0.28482136130333, 0.0, 0.95858061313629], [0.0, 1.0, 0.0], [-0.95858061313629, 0.0, -0.28482136130333], [-71.3740234375, 1.2429687976837, 94.7705078125]]
    ],
    //Donya Fortress
    "XP2_Palace": [
      [[-0.68803387880325, 0.0, -0.72567856311798], [0.0, 1.0, 0.0], [0.72567856311798, 0.0, -0.68803387880325], [-4.7138671875, 6.4001951217651, 24.580408096313]],
      [[0.74616569280624, 0.0, 0.66576027870178], [0.0, 1.0, 0.0], [-0.66576027870178, 0.0, 0.74616569280624], [19.2373046875, 6.3923826217651, 18.822265625]],
      [[-0.45880001783371, 0.0, 0.8885395526886], [0.0, 1.0, 0.0], [-0.8885395526886, 0.0, -0.45880001783371], [54.7265625, 6.7234702110291, 10.396484375]],
      [[0.54088431596756, 0.0, 0.84109699726105], [0.0, 1.0, 0.0], [-0.84109699726105, 0.0, 0.54088431596756], [54.9541015625, 1.2839844226837, -7.46875]],
      [[-0.7183825969696, 0.0, 0.69564819335938], [0.0, 1.0, 0.0], [-0.69564819335938, 0.0, -0.7183825969696], [37.5302734375, -1.2706786394119, -25.993244171143]],
      [[-0.82050997018814, 0.0, 0.57163220643997], [0.0, 1.0, 0.0], [-0.57163220643997, 0.0, -0.82050997018814], [29.26953125, 1.3337891101837, 47.42578125]],
      [[0.48163351416588, 0.0, -0.87637275457382], [0.0, 1.0, 0.0], [0.87637275457382, 0.0, 0.48163351416588], [5.525390625, 1.3464844226837, 35.1845703125]],
      [[0.19800035655499, 0.0, -0.98020195960999], [0.0, 1.0, 0.0], [0.98020195960999, 0.0, 0.19800035655499], [-30.6064453125, 6.4207029342651, 14.4873046875]],
      [[0.31970396637917, 0.0, -0.94751745462418], [0.0, 1.0, 0.0], [0.94751745462418, 0.0, 0.31970396637917], [-29.9580078125, 6.4001951217651, -17.8857421875]],
      [[0.69488847255707, 0.0, -0.71911752223969], [0.0, 1.0, 0.0], [0.71911752223969, 0.0, 0.69488847255707], [-17.296875, 6.4041013717651, -24.4619140625]]
    ]
};