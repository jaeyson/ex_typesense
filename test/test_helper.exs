defmodule ExTypesense.TestSchema.Person do
  use Ecto.Schema
  @behaviour ExTypesense

  @moduledoc false

  defimpl Jason.Encoder, for: __MODULE__ do
    def encode(value, opts) do
      value
      |> Map.take([:persons_id, :name, :country])
      |> Enum.map(fn {key, val} ->
        if key === :persons_id, do: {key, Map.get(value, :id)}, else: {key, val}
      end)
      |> Enum.into(%{})
      |> Jason.Encode.map(opts)
    end
  end

  schema "persons" do
    field(:name, :string)
    field(:country, :string)
    field(:persons_id, :integer, virtual: true)
  end

  @impl ExTypesense
  def get_field_types do
    name = __MODULE__.__schema__(:source)
    primary_field = name <> "_id"

    %{
      name: name,
      default_sorting_field: primary_field,
      fields: [
        %{name: primary_field, type: "int32"},
        %{name: "name", type: "string"},
        %{name: "country", type: "string"}
      ]
    }
  end
end

defmodule ExTypesense.TestSchema.Truck do
  use Ecto.Schema
  @behaviour ExTypesense

  @moduledoc false

  defimpl Jason.Encoder, for: __MODULE__ do
    def encode(value, opts) do
      value
      |> Map.take([:trucks_id, :name])
      |> Enum.map(fn {key, val} ->
        if key === :trucks_id, do: {key, Map.get(value, :id)}, else: {key, val}
      end)
      |> Enum.into(%{})
      |> Jason.Encode.map(opts)
    end
  end

  schema "trucks" do
    field(:name, :string)
    field(:trucks_id, :integer, virtual: true)
  end

  @impl ExTypesense
  def get_field_types do
    name = __MODULE__.__schema__(:source)
    primary_field = name <> "_id"

    %{
      name: name,
      default_sorting_field: primary_field,
      fields: [
        %{name: primary_field, type: "int32"},
        %{name: "name", type: "string"}
      ]
    }
  end
end

defmodule ExTypesense.TestSchema.MultiSearch do
  @moduledoc false

  def vector_embeddings do
    [
      0.017149745,
      -0.015301713,
      0.017461857,
      -0.01604914,
      -0.007942434,
      -0.049116608,
      -0.02695664,
      0.0586771,
      0.021108642,
      -0.01852961,
      0.0381434,
      -0.0036324114,
      -0.0063202726,
      -0.044319935,
      0.014160039,
      0.05542456,
      -0.063539475,
      -0.021322193,
      -0.05962986,
      -0.002320308,
      0.016821206,
      0.025379652,
      -2.111121e-4,
      0.0025626055,
      0.012632332,
      -0.02468972,
      -0.051514946,
      0.0017063504,
      0.024344753,
      -0.06120685,
      0.073592775,
      -0.036763534,
      -0.022291385,
      0.010250422,
      -0.023375563,
      0.013757578,
      0.01423396,
      0.06344092,
      0.008270974,
      -0.016870487,
      -0.04159306,
      -0.040870275,
      0.011400309,
      -0.00956049,
      0.004866487,
      0.018135363,
      -0.02355626,
      -0.0013726777,
      0.01361795,
      0.010611815,
      -0.0658064,
      0.0025543922,
      0.028237943,
      -0.013872567,
      -0.025428932,
      -0.018710306,
      0.025149675,
      0.030915538,
      0.0024188696,
      0.028730752,
      0.040574588,
      -0.030192751,
      0.032870345,
      0.0038069477,
      0.016435172,
      -0.018266778,
      0.008747356,
      0.05641018,
      0.017363297,
      0.01553169,
      0.048229553,
      0.021979272,
      -0.033346727,
      0.03181902,
      -0.0057576494,
      -0.034825154,
      0.032821063,
      -0.014619994,
      0.018201072,
      -0.02690736,
      -0.03268965,
      0.035416525,
      -0.0023880692,
      -0.013371545,
      -0.0016601495,
      -0.05098928,
      -0.12701325,
      -0.0013162101,
      -0.0121148825,
      -0.0012997831,
      -0.017494712,
      -0.016870487,
      -0.017379723,
      0.043202903,
      0.004817206,
      -0.038373377,
      -0.011367456,
      6.601584e-4,
      0.01739615,
      0.017067611,
      0.0014024517,
      0.004229942,
      0.0043038633,
      0.025724618,
      0.016361251,
      0.016254475,
      0.012632332,
      -0.011359243,
      -0.0060738684,
      0.018348914,
      -0.051054988,
      -0.004225835,
      0.024821136,
      0.023457699,
      -0.01966307,
      0.033970952,
      0.030701987,
      -0.06035265,
      -0.0044270656,
      -0.06130541,
      -0.043991398,
      -0.0053059077,
      0.024213338,
      -0.054274675,
      0.001065699,
      -0.007782272,
      -0.009355153,
      -0.027104482,
      -0.051186405,
      -0.0058356775,
      0.012385927,
      -0.0186446,
      0.0131579945,
      0.04008178,
      -0.009338726,
      0.016139487,
      -0.0896912,
      -0.025511067,
      -0.048229553,
      0.025511067,
      -0.018299632,
      0.016353037,
      0.031112662,
      -0.017133318,
      -0.044878453,
      -0.051054988,
      -0.026825225,
      0.013741151,
      0.013626163,
      0.0030718413,
      0.012566624,
      0.029519245,
      -0.018808868,
      -0.0448456,
      0.0022936142,
      0.00280285,
      0.024476169,
      0.010776085,
      -0.014077904,
      -0.020155879,
      0.009338726,
      0.024459742,
      -0.01274732,
      0.014891039,
      -0.021207204,
      -0.021355048,
      0.0023120944,
      -0.0027125017,
      -0.05851283,
      0.015334566,
      0.011326388,
      -0.02188071,
      -0.0257739,
      -0.0054866043,
      -0.03387239,
      -0.018743161,
      0.0089362655,
      -0.030586999,
      -0.015112802,
      -0.03278821,
      0.010406478,
      0.018923856,
      -0.018431049,
      -0.015449556,
      -0.11295177,
      -0.016238049,
      0.005112891,
      0.050595034,
      0.02117435,
      -0.01723188,
      -0.020353002,
      0.016057353,
      0.086997174,
      0.014012196,
      -0.004796672,
      -0.056344472,
      0.035580795,
      -0.0023798556,
      0.01569596,
      0.02155217,
      -0.0038931894,
      -0.031506907,
      0.019268824,
      0.03745347,
      0.0020184626,
      0.040016074,
      0.019449519,
      0.013092287,
      -0.022767765,
      -0.0015277072,
      0.09041398,
      0.013256556,
      -0.028451493,
      0.044057105,
      -0.026545966,
      -0.012607691,
      -0.06304667,
      -0.013823287,
      0.09409362,
      0.026430978,
      -0.026398124,
      0.027137337,
      0.025198955,
      0.027153764,
      -0.055096023,
      0.07365849,
      -0.012821241,
      0.005663194,
      0.045042723,
      -0.043202903,
      -0.02712091,
      -0.0052402,
      -0.025363225,
      -0.0026734876,
      0.015121016,
      -0.02334271,
      0.020648688,
      -0.020763677,
      -0.011498871,
      -0.0013675444,
      -0.030225605,
      0.025051113,
      0.0020112759,
      -0.0025359117,
      0.079375066,
      -0.026874505,
      -0.0013839713,
      -0.0032053103,
      -0.015441341,
      0.009568703,
      0.055293147,
      0.0142011065,
      0.0102339955,
      -0.050200786,
      -5.359295e-4,
      -0.011318175,
      0.004336717,
      0.019449519,
      0.054701775,
      -0.010628243,
      -0.025658911,
      -0.02556035,
      -0.03370812,
      -0.029995628,
      -0.04050888,
      -0.020155879,
      0.07530118,
      6.047174e-4,
      0.036172163,
      -0.009363367,
      -0.030981245,
      -0.0037001725,
      0.014332522,
      -0.016747285,
      -0.03139192,
      0.021782149,
      -0.031359065,
      -0.011268894,
      -0.0075728283,
      0.04425423,
      -0.025543923,
      -0.0018593265,
      -0.041198812,
      -0.004751498,
      -0.015022454,
      2.5102447e-4,
      0.035120837,
      -0.034693737,
      -0.015958792,
      0.055326,
      -0.012919803,
      -0.034858007,
      0.060944017,
      -0.010348984,
      0.009872602,
      0.0057781828,
      0.011474231,
      -0.041264523,
      -0.006677559,
      -0.027810842,
      0.046126902,
      0.022915607,
      0.03699351,
      -0.013067646,
      -0.010677524,
      0.027679427,
      -4.4840467e-4,
      0.02457473,
      -0.018398194,
      -0.008086171,
      -0.009461928,
      0.059728425,
      0.062422447,
      -0.0059095984,
      0.011334602,
      -0.048229553,
      0.013470107,
      -0.020123025,
      0.04290722,
      -0.026660955,
      -0.009987591,
      -0.052007753,
      0.020385856,
      0.014981387,
      0.0026529538,
      0.006328486,
      0.04721108,
      -0.022554215,
      0.00991367,
      0.012870522,
      -0.040147487,
      -0.026135292,
      0.0104886135,
      -0.027301606,
      -1.7902818e-4,
      -0.016870487,
      0.010899288,
      0.023835517,
      -0.0012053282,
      0.019646643,
      -0.006041014,
      -0.037847713,
      0.038044836,
      -0.030948391,
      0.04845953,
      0.032459673,
      0.03387239,
      -5.9291057e-4,
      0.033609558,
      0.030816976,
      -0.019367386,
      -0.022225676,
      0.0047063236,
      -0.0053059077,
      0.029190706,
      -0.0666606,
      0.010201141,
      0.022948463,
      0.027827268,
      0.03170403,
      0.0022176395,
      0.009388007,
      -0.0029322123,
      0.02901001,
      0.039786097,
      0.02414763,
      -0.036763534,
      -0.015260645,
      -0.00918267,
      -0.005449644,
      -0.013404399,
      0.016057353,
      0.014537859,
      0.01933453,
      -0.016361251,
      -0.029831357,
      0.026923787,
      0.07241004,
      0.067186266,
      -0.0061149355,
      0.058545683,
      0.023474125,
      3.7782008e-4,
      -0.0113017475,
      0.005067717,
      -0.009248378,
      0.012813028,
      0.011466018,
      -0.06741624,
      -0.036369286,
      0.035022277,
      -0.024279045,
      0.028747179,
      -0.06146968,
      0.0109978495,
      0.0147596225,
      0.036927804,
      0.023621967,
      0.012073815,
      -0.025001831,
      -0.00748248,
      -0.03613931,
      -0.034989424,
      -9.974245e-4,
      -0.028270798,
      0.013297624,
      -0.02657882,
      -0.021847855,
      0.014332522,
      -0.022882754,
      0.03705922,
      -0.056081638,
      0.07668105,
      0.027745133,
      0.016936194,
      0.0020585032,
      0.026808798,
      0.019268824,
      0.03080055,
      0.010891074,
      -0.03489086,
      -0.029190706,
      -0.0072278623,
      -0.043137196,
      -0.0026550072,
      0.0052073463,
      0.048065282,
      -0.024196912,
      -0.010899288,
      -0.05434038,
      -0.0026960748,
      -0.01345368,
      -0.036664974,
      0.021125069,
      -0.030028481,
      0.012870522,
      -0.011482445,
      -0.021026507,
      -0.025691764,
      -9.3736337e-4,
      -0.0038295349,
      0.010086153,
      3.819268e-4,
      -0.011950613,
      -0.0060656546,
      0.007133407,
      -0.029371403,
      0.0047104307,
      -0.0052648406,
      -0.022981316,
      0.008320255,
      -0.007408559,
      -0.014882825,
      0.031211223,
      -0.039687533,
      -0.02214354,
      0.017691836,
      0.01123604,
      -0.016730858,
      0.019893048,
      -0.005006116,
      -0.011088197,
      0.011860264,
      0.07313282,
      0.035350814,
      -0.012969084,
      -0.024065495,
      -0.0066570253,
      0.02155217,
      -0.013338691,
      -0.0012207284,
      0.002398336,
      0.008566659,
      0.016418746,
      -0.01604914,
      -0.007223755,
      -0.02128934,
      -0.010529681,
      0.017494712,
      -0.034266636,
      -0.012106669,
      0.0023880692,
      -0.030127043,
      0.021157924,
      5.8829045e-4,
      0.07332995,
      -0.055358853,
      0.022948463,
      -0.06859898,
      -0.025215382,
      0.034759447,
      0.033166032,
      0.022192823,
      -0.022521362,
      0.008542019,
      -0.00769603,
      0.0591042,
      -0.027892977,
      -0.006513289,
      -0.05365045,
      -0.028122954,
      -6.781254e-4,
      -0.015465982,
      0.028648617,
      0.015605612,
      0.008246333,
      -0.074972644,
      -0.0040533524,
      0.01810251,
      -0.0067966543,
      -0.044221375,
      0.049510855,
      -0.025363225,
      -0.03577792,
      -0.040114634,
      -0.03052129,
      0.013240129,
      0.06767907,
      0.012656972,
      -0.022324238,
      0.005281267,
      -0.0119424,
      -0.019153835,
      -0.025938168,
      -0.0486238,
      -0.008336682,
      -0.032328255,
      -0.05292766,
      -0.034825154,
      -0.0031231756,
      -0.016771926,
      -0.0280901,
      0.018168217,
      -0.019761631,
      -0.015096376,
      -0.026447404,
      0.013683657,
      -0.011227827,
      -0.0022587068,
      -0.015301713,
      0.04317005,
      -0.017642554,
      0.0016334557,
      -0.017642554,
      0.024771854,
      0.051087845,
      0.018069655,
      0.0012587158,
      -3.1621897e-4,
      0.023671249,
      0.03446376,
      -0.0057535423,
      0.027663,
      -0.0025379653,
      0.015884869,
      0.023539832,
      -7.4383325e-4,
      -0.028369358,
      -0.023211293,
      -0.0067638005,
      0.0017823251,
      0.0026488472,
      0.020648688,
      -9.671372e-4,
      0.0030081868,
      0.014981387,
      -0.022882754,
      -0.033100322,
      -0.014915679,
      0.044221375,
      -0.025806753,
      0.0280901,
      -0.05407755,
      -0.0020800638,
      0.028730752,
      0.024788281,
      0.009133389,
      -0.038439084,
      0.021601452,
      0.003197097,
      -0.009790468,
      -0.028287224,
      0.039030455,
      0.023753382,
      -0.027071629,
      0.034660883,
      0.018003948,
      0.024229765,
      0.013897208,
      0.032016143,
      -0.0040738857,
      0.012377714,
      0.03830767,
      -0.008878771,
      0.036763534,
      -0.030472009,
      0.0272359,
      0.007215542,
      -0.011038916,
      0.01177813,
      0.02032015,
      0.011244253,
      0.010348984,
      0.015055308,
      -0.0039979112,
      -0.004168341,
      -0.008722715,
      0.013281196,
      0.041724477,
      -0.017149745,
      -0.0035564366,
      0.004057459,
      7.6847366e-4,
      -0.0041827145,
      0.050529327,
      0.029420683,
      0.013133354,
      0.0019414612,
      0.029256415,
      -0.008098491,
      -0.018086081,
      -0.021387901,
      -0.017166173,
      0.0066241715,
      0.0026221534,
      -0.001068779,
      0.03213113,
      0.026283136,
      -0.04694825,
      0.008242227,
      -0.011416737,
      -0.006422941,
      0.005322335,
      0.0044886665,
      -0.03571221,
      -0.048689507,
      0.0150142405,
      0.032328255,
      -0.02679237,
      -0.014578926,
      0.030488437,
      0.016517308,
      0.026693808,
      0.015884869,
      0.033264592,
      -0.02744945,
      0.030767694,
      -0.021815002,
      -0.010316131,
      -0.002330575,
      0.034398053,
      -0.016270904,
      0.002079037,
      0.0067925476,
      -0.003897296,
      0.027843695,
      -0.059597008,
      -0.014636421,
      0.0014168252,
      0.00430797,
      -0.00769603,
      0.017346868,
      0.009470142,
      -0.029354976,
      -0.018546037,
      0.014529645,
      -0.06130541,
      0.016804779,
      0.0142011065,
      0.0061929636,
      -0.06238959,
      0.011079984,
      0.012057388,
      -0.02058298,
      -0.012164163,
      0.010751445,
      -0.011663141,
      -0.07556401,
      -0.006287419,
      0.004353144,
      0.021042936,
      0.012476276,
      -0.004973262,
      -0.028484348,
      -0.017100465,
      -0.0051539587,
      0.014463938,
      0.019860193,
      6.56565e-4,
      0.0050882506,
      -0.034233782,
      0.022521362,
      0.059662715,
      -0.006377767,
      -0.0014383856,
      -0.036927804,
      -9.0964284e-4,
      0.004096473,
      -0.022915607,
      -0.08022927,
      0.0011098464,
      -0.0012197017,
      -0.006266885,
      -0.00355233,
      -0.021256486,
      -0.014611781,
      -0.0055482057,
      0.013806859,
      0.035285108,
      0.014595353,
      -0.020911518,
      -0.0054660705,
      -0.012574838,
      0.013987556,
      0.0032669115,
      0.013116927,
      -0.018053228,
      -0.037584882,
      -0.010258636,
      0.020993654,
      -0.0118109835,
      0.05292766,
      0.012698039,
      -0.011991681,
      0.0025297517,
      -0.002864451,
      0.017363297,
      -0.010792512,
      8.2802144e-4,
      -0.008928052,
      0.011581006,
      -0.020451564,
      -0.017708262,
      -0.0042710095,
      -0.015424915,
      0.011548152,
      -0.006500969,
      0.0060656546,
      -0.016525522,
      -0.030455582,
      -0.019580936,
      0.0076138955,
      9.306899e-4,
      0.0129033765,
      -0.0339381,
      0.010808939,
      0.032591086,
      0.02296489,
      -0.0056714076,
      -0.046915397,
      0.010012232,
      0.015309926,
      -0.0131005,
      0.016812993,
      -0.0017515245,
      -0.030636279,
      0.01539206,
      -0.003447608,
      -0.0019301677,
      0.04980654,
      0.006710413,
      0.04704681,
      -0.04241441,
      0.007223755,
      -0.020648688,
      -0.015055308,
      -0.002858291,
      0.01956451,
      0.043728564,
      0.016533734,
      0.015277072,
      -0.0037946275,
      -0.0020287295,
      -0.008977333,
      0.027663,
      -0.010086153,
      -0.006414728,
      0.020057317,
      0.002147825,
      0.012032747,
      0.014003983,
      0.0080204625,
      0.0070923395,
      0.013141568,
      -9.799708e-4,
      3.5086958e-4,
      0.026332416,
      0.011868478,
      -0.058052875,
      -0.032065425,
      -0.012673399,
      0.011958826,
      0.005634447,
      0.004357251,
      0.019728778,
      -0.011030703,
      -0.0011262734,
      -0.07076734,
      0.01347832,
      -0.033478145,
      -0.025051113,
      0.015835589,
      0.029634235,
      0.022159968,
      0.028435066,
      -0.016032713,
      0.0037843608,
      0.02101008,
      -0.030274887,
      -0.032459673,
      -0.055030312,
      0.029092144,
      -7.828473e-4,
      0.010340771,
      0.008312041,
      -0.014882825,
      0.029371403,
      -0.0047843517,
      5.7905033e-4,
      0.01576988,
      0.032229695,
      -0.037584882,
      -0.046258315,
      -0.021617878,
      0.01385614,
      0.02728518,
      -0.041724477,
      0.019728778,
      0.009732974,
      0.0115563655,
      -0.04208587,
      -0.019252397,
      -0.008188839,
      -0.012353074,
      0.021092216,
      0.03370812,
      -0.016328398,
      -0.024164056,
      0.0021724654,
      -0.020106599,
      0.048689507,
      0.0034291279,
      -0.03561365,
      0.0028254369,
      0.0109978495,
      0.005802823,
      -0.0176097,
      -0.0015164136,
      -0.022784192,
      0.018463902,
      -0.0014907465,
      -0.030603426,
      0.062652424,
      -0.022340665,
      -0.012550197,
      -0.026726663,
      0.0028295438,
      -0.026513113,
      -0.011720635,
      0.0048500597,
      -0.030701987,
      0.015539903,
      0.013486533,
      -0.055884514,
      0.036796387,
      -0.026726663,
      0.011318175,
      0.05266483,
      0.036073603,
      0.013626163,
      -0.005338762,
      -0.026759516,
      -0.04024605,
      7.941408e-4,
      0.0022566535,
      0.023375563,
      -0.010554321,
      9.183697e-4,
      0.01347832,
      0.022521362,
      0.01640232,
      -2.0110191e-4,
      0.021240057,
      -0.011186759,
      -0.009084108,
      -0.011498871,
      -0.005408576,
      0.018020375,
      -0.016747285,
      -0.0036837456,
      0.01291159,
      -0.008180626,
      0.025741044,
      -0.026003877,
      -0.05736294,
      -0.010537894,
      4.5610478e-4,
      0.012952657,
      -0.016016286,
      0.023359137,
      0.02533037,
      -0.020139452,
      -0.005539992,
      0.0069362833,
      -4.6380493e-4,
      -0.031506907,
      -0.010250422,
      -0.020927947,
      -0.003158083,
      0.024114776,
      0.008283294,
      -0.03909616,
      2.0828871e-4,
      0.009034827,
      0.016730858,
      -0.024394035,
      0.005268947,
      0.00429565,
      0.020632261,
      -0.02771228,
      -0.013166208,
      -0.05893993,
      -0.0077083507,
      0.014390016,
      -0.021798575,
      -0.011318175,
      0.031950437,
      0.018086081,
      0.052697685,
      -0.015104589,
      8.341815e-4,
      0.03788057,
      -0.021092216,
      0.01690334,
      -0.00655025,
      0.012254512,
      -0.018923856,
      0.017741116,
      0.012919803,
      0.007342851,
      0.0061477893,
      -0.017281162,
      -0.033297446,
      -0.023506979,
      0.058315706,
      -0.039161872,
      0.013585095,
      -0.005445537,
      0.010332557,
      -0.0121395225,
      0.007576935,
      -0.060319796,
      0.020697968,
      -0.04100169,
      -8.701155e-4,
      3.9758376e-4,
      0.0050800373,
      -0.027153764,
      0.022833474,
      0.0025584989,
      0.015055308,
      0.0104804,
      -0.019728778,
      -0.037354905,
      0.028221516,
      -0.0017443377,
      6.137651e-5,
      -0.022192823,
      0.026611675,
      0.004652936,
      0.0024804708,
      -0.011383883,
      0.022603495,
      -0.015638465,
      0.028237943,
      -0.007724778,
      0.010751445,
      0.038044836,
      0.059334178,
      -0.02381909,
      0.032278974,
      0.06321094,
      0.0021724654,
      -0.017100465,
      0.021371474,
      0.013346904,
      0.023375563,
      -0.005704262,
      0.004607762,
      -0.0031005885,
      -0.0012176484,
      0.003780254,
      0.010907501,
      0.030636279,
      0.005281267,
      -0.018776014,
      -0.013207275,
      0.030866256,
      -0.031786166,
      0.02058298,
      0.008307935,
      0.008012249,
      0.0055112448,
      0.0086323675,
      0.0066529186,
      -0.025198955,
      0.028500775,
      -2.4293932e-4,
      -0.012591264,
      0.008681648,
      -0.005712475,
      -0.039621826,
      -0.038899038,
      -0.043202903,
      0.02464044,
      -9.938311e-4,
      -0.018956712,
      0.013626163,
      -0.022570642,
      -0.022784192,
      0.014661062,
      -0.012484489,
      0.020057317,
      -0.009946524,
      -5.130858e-4,
      -0.0045092003,
      0.034332346,
      -0.005203239,
      0.03139192,
      0.030324167,
      -0.009437288,
      0.029125,
      -0.023983361,
      0.019531654,
      0.02381909,
      0.017560419,
      0.01954808,
      -0.00915803,
      0.015079949,
      -0.03577792,
      0.007724778,
      -0.0010698057,
      0.020139452,
      -0.0020225693,
      0.020648688,
      -0.0026858079,
      0.018086081,
      6.360313e-4,
      0.023687676,
      0.002375749,
      0.0047638183,
      -0.02960138,
      -0.0186446,
      -0.0121148825,
      -0.029667089,
      0.022077832,
      0.0025954596,
      -0.03554794,
      -0.012566624,
      0.026611675,
      -0.020812957,
      -0.0112524675,
      -0.011893119,
      -0.006344913,
      0.010891074,
      -0.009141603,
      -0.0054332167,
      0.005539992,
      -0.016295543,
      0.030340593,
      0.012312006,
      -0.008747356,
      0.026644528,
      0.004402425,
      0.0347923,
      0.004158074,
      0.001534894,
      -0.01836534,
      0.0021888923,
      -0.01977806,
      0.020287294,
      0.010973209,
      0.018348914,
      -0.026710236,
      0.014693915,
      0.019958755,
      0.007597469,
      0.0053634024,
      0.019038845,
      0.0014291455,
      0.009437288,
      -0.0061477893,
      0.026266707,
      0.004985582,
      0.0047556045,
      0.02879646,
      0.027465876,
      0.027104482,
      0.00988903,
      -0.016591229,
      -0.006570784,
      0.035909332,
      -0.0056015933,
      0.009149816,
      -0.0050307564,
      -0.03198329,
      0.01933453,
      -0.018217498,
      -0.011950613,
      0.00842703,
      -0.011293534,
      -0.0041539674,
      0.025051113,
      0.0028890914,
      0.024279045,
      -0.011121051,
      0.0015194938,
      -0.013921848,
      -0.020238014,
      3.9399034e-4,
      -0.018513182,
      -0.026513113,
      0.06866469,
      0.016739072,
      0.016131274,
      0.010119007,
      -0.0059958403,
      0.027153764,
      -0.009634412,
      0.02214354,
      0.05013508,
      0.0115317255,
      0.005572846,
      -0.016246263,
      -0.03370812,
      -0.027482303,
      -0.009995805,
      0.0073346375,
      -0.0036508916,
      -0.035580795,
      -0.009412647,
      -0.021256486,
      0.03656641,
      0.019465948,
      0.014874612,
      -6.016374e-4,
      0.0025502853,
      0.14613423,
      -0.0015698012,
      -0.019646643,
      0.010275063,
      0.016410531,
      -6.5810507e-4,
      -0.011351028,
      0.015975218,
      -0.038504794,
      9.902377e-4,
      -0.02020516,
      -0.012238084,
      0.018053228,
      -0.0057822894,
      0.014652847,
      0.004607762,
      -0.037354905,
      -0.043137196,
      -0.0030574678,
      -0.027334461,
      0.024624012,
      -0.0012679559,
      0.020353002,
      0.008566659,
      -0.012443421,
      -0.040968835,
      -0.026513113,
      -0.017971093,
      0.02457473,
      -0.0010292516,
      0.019925902,
      0.046422586,
      0.018808868,
      0.011654927,
      0.005412683,
      0.026201,
      -0.016188769,
      0.024344753,
      0.0028603442,
      -0.024295473,
      -0.031129088,
      -0.0055810595,
      -0.01553169,
      0.0063983006,
      0.006484542,
      0.009248378,
      -0.04412281,
      -0.040870275,
      0.0013695977,
      -0.021519316,
      -0.04753962,
      -0.0036673187,
      -0.015424915,
      0.013018365,
      0.030701987,
      -0.03548223,
      0.040114634,
      0.030669132,
      0.018348914,
      -0.0070471657,
      0.018743161,
      -0.016673364,
      0.0029342656,
      0.030997673,
      0.005112891,
      -0.0089362655,
      0.024788281,
      0.050036516,
      -0.010422906,
      0.009585131,
      0.018233925,
      0.020862238,
      0.021075789,
      -0.03689495,
      0.009338726,
      7.443466e-4,
      0.021634305,
      -0.018053228,
      -0.021732867,
      0.0063038454,
      -0.0058274637,
      0.017823251,
      0.05181063,
      0.020123025,
      -0.05769148,
      0.0012443422,
      -0.013798646,
      -0.01815179,
      -0.015309926,
      -0.018217498,
      -0.023490552,
      -0.004620082,
      0.0063243792,
      0.016344825,
      -0.010381838,
      0.008476311,
      -0.05250056,
      -0.01857889,
      0.0142257465,
      0.012969084,
      0.017593274,
      4.443621e-5,
      -0.015843803,
      0.010710377,
      -0.022192823,
      -0.0034435014,
      -0.043728564,
      -4.1349736e-4,
      -0.021519316,
      0.009626199,
      0.0032155772,
      0.0030554144,
      -0.007962968,
      0.011482445,
      0.032870345,
      0.02721947,
      0.004759711,
      0.05013508,
      -0.016295543,
      -0.021535743,
      0.0042217285,
      0.022373518,
      -0.0054373234,
      -0.0073346375,
      -0.0094455015,
      -0.012509129,
      0.01793824,
      0.01050504,
      0.016008072,
      -0.019055273,
      0.023260575,
      -0.0055317786,
      0.025379652,
      -0.008135452,
      0.008102598,
      0.010570749,
      -0.01142495,
      -0.01536742,
      -0.0035872373,
      0.018595317,
      -0.014808903,
      0.002852131,
      -0.0039732708,
      -0.02641455,
      -0.0077001373,
      0.012771961,
      0.014981387,
      0.010702164,
      -0.010217569,
      -0.0045174137,
      -0.006201177,
      0.020927947,
      0.017823251,
      -0.0243119,
      -0.005445537,
      0.015416701,
      0.013051219,
      -0.006595424,
      -0.007289463,
      0.011063557,
      -0.01793824,
      -2.744778e-5,
      -0.025100393,
      -0.003213524,
      -0.0015492676,
      -0.025297517,
      -0.005930132,
      -0.0012494756,
      0.012098456,
      -0.02079653,
      0.013995769,
      -2.6719476e-4,
      0.02820509,
      0.012936231,
      -0.0036734787,
      -0.023753382,
      -0.011548152,
      0.03955612,
      -0.01701833,
      0.001603682,
      0.011186759,
      -0.024722574,
      -0.012032747,
      0.0026139398,
      0.0070471657,
      0.022061406,
      0.021059362,
      -0.017379723,
      -0.016205195,
      0.01539206,
      0.051876336,
      0.0032299508,
      -0.006435261,
      0.035810772,
      0.011934186,
      0.0042422623,
      -0.02910857,
      -0.0228499,
      -0.04786816,
      0.016246263,
      -0.0038151613,
      0.04034461,
      0.012279152,
      0.023326281,
      -0.002548232,
      0.02728518,
      -0.017543992,
      -0.015605612,
      -0.012098456,
      -0.022061406,
      0.053190496,
      0.02603673,
      -0.04786816,
      0.009141603,
      0.0030102404,
      -0.014874612,
      0.011088197,
      0.03354385,
      -0.01517851,
      -0.0070800195,
      0.02155217,
      -0.008550232,
      0.015778095,
      -0.014866398,
      0.013905421,
      -0.018053228,
      0.03955612,
      -0.021141497,
      -0.004858273,
      0.013297624,
      -0.003281285,
      0.0026509005,
      -0.021913564,
      -0.0065256096,
      -0.011063557,
      0.00729357,
      -0.0238848,
      0.025051113,
      -0.015605612,
      -0.029190706,
      -0.020697968,
      -0.042512972,
      -0.023326281,
      0.026332416,
      -0.006977351,
      -0.01744543,
      0.006455795,
      -0.024295473,
      0.008977333,
      -2.0777537e-4,
      0.014874612,
      0.034398053,
      -0.005556419,
      0.01312514,
      -0.031030526,
      -0.048262406,
      0.026710236,
      -0.0025441253,
      0.025100393,
      -0.021617878,
      -0.04914946,
      -0.024492595,
      0.022061406,
      -0.0016888968,
      0.02036943,
      -0.034398053,
      0.035580795,
      0.01458714,
      -0.024328327,
      0.023671249,
      -0.018053228,
      -0.039950363,
      -0.0023079878,
      0.014907465,
      -0.011515299,
      0.015786307,
      -0.02268563,
      0.015022454,
      -0.009478356,
      -0.028665043,
      3.408915e-7,
      0.0021519316,
      -0.01912098,
      0.002753569,
      -0.021634305,
      -0.0031786165,
      0.0034599283,
      0.005839784,
      0.012780175,
      -0.006123149,
      -0.0053592953,
      -0.0030061335,
      -0.008110811,
      0.008870558,
      0.015145657,
      0.014028623,
      0.03991751,
      -0.017034756,
      -0.025379652,
      -0.026874505,
      -0.028122954,
      -0.017921813,
      0.036270726,
      -0.018710306,
      -0.0036611585,
      -0.020008037,
      0.033905245,
      0.022340665,
      -0.017116891,
      0.025313944,
      -0.020073744,
      0.028385786,
      0.016591229,
      -0.012583051,
      0.004969155,
      0.0033120858,
      -0.02409835,
      0.009125176,
      -0.007355171,
      6.165243e-4,
      0.012106669,
      0.014677488,
      0.008004036,
      0.011038916,
      0.040935982,
      0.015975218,
      0.021585025,
      5.436297e-4,
      0.014718556,
      7.67447e-4,
      -0.017215453,
      -0.03906331,
      0.03257466,
      -0.011654927,
      0.057165816,
      -0.01777397,
      -0.043794274,
      -0.014291454,
      0.0038110546,
      -0.019301677,
      -0.0071703675,
      0.019909475,
      0.0066159577,
      0.014242174,
      0.018776014,
      0.0018726734,
      -0.0022176395,
      0.015194938,
      0.03489086,
      -0.008324361,
      -0.027613718,
      0.01458714,
      0.029831357,
      0.011334602,
      -0.031671178,
      0.0026611674,
      0.015967004,
      0.01564668,
      0.0011817144,
      -0.0030266673,
      0.018973138,
      -0.0021663052,
      0.0021683585,
      -0.018266778,
      -0.00993831,
      0.021601452,
      -0.0032114706,
      0.006127256,
      0.021585025,
      -0.015761668,
      -0.015145657,
      0.00896912,
      0.015408488,
      -0.035843626,
      0.027383741,
      -0.021059362,
      -0.0063531264,
      -0.001160154,
      -0.014702128,
      -0.02917428,
      0.0097494,
      0.026496686,
      0.01982734,
      0.003989698,
      0.02058298,
      -0.0027268752,
      0.003086215,
      -0.02414763,
      0.0041724476
    ]
  end
end

defmodule ExTypesense.TestSchema.Product do
  use Ecto.Schema
  @behaviour ExTypesense

  @moduledoc false

  defimpl Jason.Encoder, for: __MODULE__ do
    def encode(value, opts) do
      value
      |> Map.take([:poducts_id, :name, :description])
      |> Enum.map(fn {key, val} ->
        if key === :products_id, do: {key, Map.get(value, :id)}, else: {key, val}
      end)
      |> Enum.into(%{})
      |> Jason.Encode.map(opts)
    end
  end

  schema "products" do
    field(:name, :string)
    field(:description, :string)
    field(:products_id, :integer, virtual: true)
  end

  @impl ExTypesense
  def get_field_types do
    name = __MODULE__.__schema__(:source)
    primary_field = name <> "_id"

    %{
      name: name,
      default_sorting_field: primary_field,
      fields: [
        %{name: primary_field, type: "int32"},
        %{name: "name", type: "string"},
        %{name: "description", type: "string"}
      ]
    }
  end
end

defmodule ExTypesense.TestSchema.House do
  use Ecto.Schema
  @behaviour ExTypesense

  @moduledoc false

  defimpl Jason.Encoder, for: __MODULE__ do
    def encode(value, opts) do
      value
      |> Map.take([:houses_id, :name])
      |> Enum.map(fn {key, val} ->
        if key === :houses_id, do: {key, Map.get(value, :id)}, else: {key, val}
      end)
      |> Enum.into(%{})
      |> Jason.Encode.map(opts)
    end
  end

  schema "houses" do
    field(:name, :string)
    field(:houses_id, :integer, virtual: true)
  end

  @impl ExTypesense
  def get_field_types do
    name = __MODULE__.__schema__(:source)
    primary_field = name <> "_id"

    %{
      name: name,
      default_sorting_field: primary_field,
      fields: [
        %{name: primary_field, type: "int32"},
        %{name: "name", type: "string"}
      ]
    }
  end
end

defmodule ExTypesense.TestSchema.Car do
  use Ecto.Schema
  @behaviour ExTypesense

  @moduledoc false

  defimpl Jason.Encoder, for: __MODULE__ do
    def encode(value, opts) do
      value
      |> Map.take([:cars_id, :name])
      |> Enum.map(fn {key, val} ->
        if key === :cars_id, do: {key, Map.get(value, :id)}, else: {key, val}
      end)
      |> Enum.into(%{})
      |> Jason.Encode.map(opts)
    end
  end

  schema "cars" do
    field(:name, :string)
    field(:cars_id, :integer, virtual: true)
  end

  @impl ExTypesense
  def get_field_types do
    name = __MODULE__.__schema__(:source)
    primary_field = name <> "_id"

    %{
      name: name,
      default_sorting_field: primary_field,
      fields: [
        %{name: primary_field, type: "int32"},
        %{name: "name", type: "string"}
      ]
    }
  end
end

defmodule ExTypesense.TestSchema.Catalog do
  use Ecto.Schema
  @behaviour ExTypesense

  @moduledoc false

  defimpl Jason.Encoder, for: __MODULE__ do
    def encode(value, opts) do
      value
      |> Map.take([:catalogs_id, :name, :description])
      |> Enum.map(fn {key, val} ->
        if key === :catalogs_id, do: {key, Map.get(value, :id)}, else: {key, val}
      end)
      |> Enum.into(%{})
      |> Jason.Encode.map(opts)
    end
  end

  schema "catalogs" do
    field(:name, :string)
    field(:description, :string)
    field(:catalogs_id, :integer, virtual: true)
  end

  @impl ExTypesense
  def get_field_types do
    name = __MODULE__.__schema__(:source)
    primary_field = name <> "_id"

    %{
      name: name,
      default_sorting_field: primary_field,
      fields: [
        %{name: primary_field, type: "int32"},
        %{name: "name", type: "string"},
        %{name: "description", type: "string"}
      ]
    }
  end
end

defmodule ExTypesense.TestSchema.Credential do
  use Ecto.Schema

  @moduledoc false

  schema "credentials" do
    field(:node, :string)
    field(:secret_key, :string)
    field(:port, :integer)
    field(:scheme, :string)
  end
end

ExUnit.start()
