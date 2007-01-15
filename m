From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 15 Jan 2007 13:30:20 +0000
Subject: When not resetting t_nom, negative credit never clears
Message-Id: <200701151330.20366@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Here is a log which I took after dropping the 3d patch which resets t_nom when tnom < t_now.
It shows that the negative credit does not clear, hence all packets are sent in one huge burst.


[   75.646215] ccid3_hc_tx_update_x: X_prev#743226, X_now#728510, X_calc=0, X_recv864255
[   75.646218] ccid3_update_send_interval: t_ipiY, delta), s15, X#728510
[   75.646223] ccid3_hc_tx_packet_recv: client(f651c080), RTTD98us (sampleU17us), s15, p=0, X_calc=0, X_recv864255, X#728510
[   75.646264] ccid3_hc_tx_send_packet: delay=-14235
[   75.646314] ccid3_hc_tx_send_packet: delay=-14226
[   75.646451] ccid3_hc_tx_send_packet: delay=-14304
[   75.646454] ccid3_hc_tx_update_win_count: now at 0X3
[   75.646548] ccid3_hc_tx_send_packet: delay=-14343
[   75.646759] ccid3_hc_tx_send_packet: delay=-14494
[   75.646802] ccid3_hc_tx_send_packet: delay=-14479
[   75.646923] ccid3_hc_tx_send_packet: delay=-14541
[   75.647045] ccid3_hc_tx_send_packet: delay=-14604
[   75.647205] ccid3_hc_tx_send_packet: delay=-14705
[   75.647266] ccid3_hc_tx_send_packet: delay=-14707
[   75.647384] ccid3_hc_tx_send_packet: delay=-14767
[   75.647564] ccid3_hc_tx_send_packet: delay=-14888
[   75.647623] ccid3_hc_tx_send_packet: delay=-14888
[   75.647627] ccid3_hc_tx_update_win_count: now at 0X4
[   75.647812] ccid3_hc_tx_send_packet: delay=-15018
[   75.647907] ccid3_hc_tx_send_packet: delay=-15055
[   75.647984] ccid3_hc_tx_send_packet: delay=-15072
[   75.648114] ccid3_hc_tx_send_packet: delay=-15144
[   75.648223] ccid3_hc_tx_send_packet: delay=-15194
[   75.648373] ccid3_hc_tx_send_packet: delay=-15285
[   75.648526] ccid3_hc_tx_send_packet: delay=-15380
[   75.648657] ccid3_hc_tx_send_packet: delay=-15452
[   75.648706] ccid3_hc_tx_send_packet: delay=-15442
[   75.648820] ccid3_hc_tx_send_packet: delay=-15498
[   75.648824] ccid3_hc_tx_update_win_count: now at 0X5
[   75.649013] ccid3_hc_tx_send_packet: delay=-15631
[   75.649060] ccid3_hc_tx_send_packet: delay=-15620
[   75.649223] ccid3_hc_tx_send_packet: delay=-15724
[   75.649333] ccid3_hc_tx_send_packet: delay=-15775
[   75.649419] ccid3_hc_tx_send_packet: delay=-15802
[   75.649537] ccid3_hc_tx_send_packet: delay=-15862
[   75.649657] ccid3_hc_tx_send_packet: delay=-15922
[   75.649788] ccid3_hc_tx_send_packet: delay=-15995
[   75.649934] ccid3_hc_tx_send_packet: delay=-16082
[   75.650066] ccid3_hc_tx_send_packet: delay=-16155
[   75.650069] ccid3_hc_tx_update_win_count: now at 0X6
[   75.650137] ccid3_hc_tx_send_packet: delay=-16167
[   75.650256] ccid3_hc_tx_send_packet: delay=-16228
[   75.650442] ccid3_hc_tx_send_packet: delay=-16355
[   75.650499] ccid3_hc_tx_send_packet: delay=-16353
[   75.650666] ccid3_hc_tx_send_packet: delay=-16461
[   75.650771] ccid3_hc_tx_send_packet: delay=-16508
[   75.650855] ccid3_hc_tx_send_packet: delay=-16533
[   75.650974] ccid3_hc_tx_send_packet: delay=-16593
[   75.651076] dccp_v4_rcv:      ACK src9.133.209.65@5001  dst9.133.209.75@33438 seq4797824647, ack 51983126
[   75.651086] ccid3_hc_tx_parse_options: client(f651c080), RECEIVE_RATE876322
[   75.651090] ccid3_hc_tx_parse_options: client(f651c080), LOSS_EVENT_RATEB94967295
[   75.651094] dccp_parse_options: client rx opt: TIMESTAMP3608, ackno 51983126
[   75.651098] dccp_parse_options: client rx opt: NDP countG
[   75.651103] ccid3_hc_tx_update_x: X_prev#728510, X_now#752644, X_calc=0, X_recv876322
[   75.651107] ccid3_update_send_interval: t_ipiY, delta), s15, X#752644
[   75.651112] ccid3_hc_tx_packe.748504] ccid3_hc_tx_send_packet: delay=-66203
[   75.748624] ccid3_hc_tx_send_packet: delay=-66264
[   75.748836] ccid3_hc_tx_send_packet: delay=-66418
[   75.748880] ccid3_hc_tx_send_packet: delay=-66403
[   75.749011] ccid3_hc_tx_send_packet: delay=-66474
[   75.749159] ccid3_hc_tx_send_packet: delay=-66563
[   75.749222] ccid3_hc_tx_send_packet: delay=-66568
[   75.749340] ccid3_hc_tx_send_packet: delay=-66627
[   75.749344] ccid3_hc_tx_update_win_count: now at 0X0
[   75.749527] ccid3_hc_tx_send_packet: delay=-66755
[   75.749586] ccid3_hc_tx_send_packet: delay=-66756
[   75.749757] ccid3_hc_tx_send_packet: delay=-66867
[   75.749820] ccid3_hc_tx_send_packet: delay=-66872
[   75.749936] ccid3_hc_tx_send_packet: delay=-66929
[   75.750056] ccid3_hc_tx_send_packet: delay=-66990
[   75.750175] ccid3_hc_tx_send_packet: delay=-67051
[   75.750298] ccid3_hc_tx_send_packet: delay=-67114
[   75.750423] ccid3_hc_tx_send_packet: delay=-67180
[   75.750540] ccid3_hc_tx_send_packet: delay=-67239
[   75.750657] dccp_v4_rcv:      ACK src9.133.209.65@5001  dst9.133.209.75@33438 seq4797824666, ack 51983958
[   75.750666] ccid3_hc_tx_parse_options: client(f651c080), RECEIVE_RATE948536
[   75.750670] ccid3_hc_tx_parse_options: client(f651c080), LOSS_EVENT_RATEB94967295
[   75.750674] dccp_parse_options: client rx opt: TIMESTAMP3580, ackno 51983958
[   75.750677] dccp_parse_options: client rx opt: NDP countf
[   75.750682] ccid3_hc_tx_update_x: X_prev#637034, X_now#897072, X_calc=0, X_recv948536
[   75.750686] ccid3_update_send_interval: t_ipiY, delta), s15, X#897072
[   75.750691] ccid3_hc_tx_packet_recv: client(f651c080), RTTS41us (sampleT63us), s15, p=0, X_calc=0, X_recv948536, X#897072
[   75.750740] ccid3_hc_tx_send_packet: delay=-67380
[   75.750746] ccid3_hc_tx_update_win_count: now at 0X1
[   75.750795] ccid3_hc_tx_send_packet: delay=-67377
[   75.750950] ccid3_hc_tx_send_packet: delay=-67473
[   75.751017] ccid3_hc_tx_send_packet: delay=-67481
[   75.751134] ccid3_hc_tx_send_packet: delay=-67539
[   75.751248] ccid3_hc_tx_send_packet: delay=-67595
[   75.751372] ccid3_hc_tx_send_packet: delay=-67660
[   75.751514] ccid3_hc_tx_send_packet: delay=-67743
[   75.751612] ccid3_hc_tx_send_packet: delay=-67782
[   75.751850] ccid3_hc_tx_send_packet: delay=-67961
[   75.751885] ccid3_hc_tx_send_packet: delay=-67938
[   75.751971] ccid3_hc_tx_send_packet: delay=-67964
[   75.752130] ccid3_hc_tx_send_packet: delay=-68065
[   75.752134] ccid3_hc_tx_update_win_count: now at 0X2
[   75.752242] ccid3_hc_tx_send_packet: delay=-68118
[   75.752334] ccid3_hc_tx_send_packet: delay=-68151
[   75.752452] ccid3_hc_tx_send_packet: delay=-68210
[   75.752664] ccid3_hc_tx_send_packet: delay=-68363
[   75.752706] ccid3_hc_tx_send_packet: delay=-68347
[   75.752809] ccid3_hc_tx_send_packet: delay=-68391
[   75.752928] ccid3_hc_tx_send_packet: delay=-68451
[   75.753057] ccid3_hc_tx_send_packet: delay=-68521
[   75.753167] ccid3_hc_tx_send_packet: delay=-68573
[   75.753287] ccid3_hc_tx_send_packet: delay=-68634
[   75.753420] ccid3_hc_tx_send_packet: delay=-68707
[   75.753526] ccid3_hc_tx_send_packet: delay=-68755
[   75.753529] ccid3_hc_tx_update_win_count: now at 0X3
[   75.753646] ccid3_hc_tx_send_packet: delay=-68817
[   75.753774] ccid3_hc_tx_send_packet: delay=-68886
[   75.753885] ccid3_hc_tx_send_packet: delay=-68937
[   75.754005] ccid3_hc_tx_send_packet: delay=-68998
[   75.754168] ccid3_hc_tx_send_packet: delay=-69103
[   75.754245] ccid3_hc_tx_send_packet: delay=-69121
[   75.754434] ccid3_hc_tx_send_packet: delay=-69251
[   75.754492] ccid3_hc_tx_send_packet: delay=-69250
[   75.754607] ccid3_hc_tx_send_packet: delay=-69307
[   75.754738] ccid3_hc_tx_send_packet: delay=-69d3_hc_tx_update_win_count: now at 0X3
[   75.867811] ccid3_hc_tx_send_packet: delay=-126884
[   75.867972] ccid3_hc_tx_send_packet: delay=-126987
[   75.868076] ccid3_hc_tx_send_packet: delay=-127032
[   75.868170] ccid3_hc_tx_send_packet: delay=-127067
[   75.868290] ccid3_hc_tx_send_packet: delay=-127129
[   75.868497] ccid3_hc_tx_send_packet: delay=-127277
[   75.868539] ccid3_hc_tx_send_packet: delay=-127260
[   75.868686] dccp_v4_rcv:      ACK src9.133.209.65@5001  dst9.133.209.75@33438 seq4797824688, ack 51984944
[   75.868695] ccid3_hc_tx_parse_options: client(f651c080), RECEIVE_RATE879866
[   75.868699] ccid3_hc_tx_parse_options: c_recv879866
[   75.868714] ccid3_update_send_interval: t_ipiY, delta), s15, X#759732
[   75.868719] ccid3_hc_tx_packet_recv: client(f651c080), RTTT31us (sampleT71us), s15, p=0, X_calc=0, X_recv879866, X#759732
[   75.868748] ccid3_hc_tx_send_packet: delay=-127411
[   75.868859] ccid3_hc_tx_send_packet: delay=-127463
[   75.868983] ccid3_hc_tx_send_packet: delay=-127527
[   75.869028] ccid3_hc_tx_send_packet: delay=-127513
[   75.869212] ccid3_hc_tx_send_packet: delay=-127639
[   75.869215] ccid3_hc_tx_update_win_count: now at 0X4
[   75.869261] ccid3_hc_tx_send_packet: delay=-127627
[   75.869435] ccid3_hc_tx_send_packet: delay=-127744
[   75.869533] ccid3_hc_tx_send_packet: delay=-127783
[   75.869607] ccid3_hc_tx_send_packet: delay=-127799
[   75.869735] ccid3_hc_tx_send_packet: delay=-127868
[   75.869847] ccid3_hc_tx_send_packet: delay=-127921
[   75.870051] ccid3_hc_tx_send_packet: delay=-128066
[   75.870092] ccid3_hc_tx_send_packet: delay=-128049
[   75.870238] ccid3_hc_tx_send_packet: delay=-128135
[   75.870385] ccid3_hc_tx_send_packet: delay=-128223
[   75.870446] ccid3_hc_tx_send_packet: delay=-128226
[   75.870564] ccid3_hc_tx_send_packet: delay=-128285
[   75.870834] ccid3_hc_tx_send_packet: delay=-128496
[   75.870837] ccid3_hc_tx_update_win_count: now at 0X5
[   75.870872] ccid3_hc_tx_send_packet: delay=-128476
[   75.870926] ccid3_hc_tx_send_packet: delay=-128471
[   75.871108] ccid3_hc_tx_send_packet: delay=-128594
[   75.871165] ccid3_hc_tx_send_packet: delay=-128592
[   75.871278] ccid3_hc_tx_send_packet: delay=-128646
[   75.871399] ccid3_hc_tx_send_packet: delay=-128708
[   75.871518] ccid3_hc_tx_send_packet: delay=-128769
[   75.871637] ccid3_hc_tx_send_packet: delay=-128829
[   75.871758] ccid3_hc_tx_send_packet: delay=-128891
[   75.871880] ccid3_hc_tx_send_packet: delay=-128954
[   75.872004] ccid3_hc_tx_send_packet: delay=-129019
[   75.872120] ccid3_hc_tx_send_packet: delay=-129077
[   75.872272] ccid3_hc_tx_send_packet: delay=-129170
[   75.872276] ccid3_hc_tx_update_win_count: now at 0X6
[   75.872356] ccid3_hc_tx_send_packet: delay=-129195
[   75.872543] ccid3_hc_tx_send_packet: delay=-129323
[   75.872601] ccid3_hc_tx_send_packet: delay=-129322
[   75.872781] ccid3_hc_tx_send_packet: delay=-129444
[   75.872839] ccid3_hc_tx_send_packet: delay=-129443
[   75.872954] ccid3_hc_tx_send_packet: delay=-129499
[   75.873079] ccid3_hc_tx_send_packet: delay=-129565
[   75.873321] ccid3_hc_tx_send_packet: delay=-129749
[   75.873355] ccid3_hc_tx_send_packet: delay=-129724
[   75.873528] ccid3_hc_tx_send_packet: delay=-129838
[   75.873601] ccid3_hc_tx_send_packet: delay=-129851
[   75.873675] ccid3_hc_tx_send_packet: delay=-129867
[   75.873679] ccid3_hc_tx_update_win_count: now at 0X7
[   75.873819] ccid3_hc_tx_send_packet: delay=-129952
[   75.873917] ccid3_hc_tx_send_packet: delay=-129991
[   75.874005] dccp_v4_rcv:      ACK src9.133.209.65@5001  dst9.133.209.75@33438 seq4797824689, ack 51984989
[   75.874015] ccid3_hc_tx_parse_options: client(f651c080), RECEIVE_RATE879866
[   75.874019] ccid3_hc_t ccid3_hc_tx_send_packet: delay=-182027
[   75.976478] ccid3_hc_tx_send_packet: delay=-182070
[   75.976590] ccid3_hc_tx_send_packet: delay=-182124
[   75.976709] ccid3_hc_tx_send_packet: delay=-182184
[   75.976907] ccid3_hc_tx_send_packet: delay=-182323
[   75.976954] ccid3_hc_tx_send_packet: delay=-182311
[   75.977082] ccid3_hc_tx_send_packet: delay=-182380
[   75.977252] ccid3_hc_tx_send_packet: delay=-182491
[   75.977310] ccid3_hc_tx_send_packet: delay=-182490
[   75.977440] ccid3_hc_tx_send_packet: delay=-182562
[   75.977619] ccid3_hc_tx_send_packet: delay=-182681
[   75.977622] ccid3_hc_tx_update_win_count: now at 0X0
[   75.977669] ccid3_hc_tx_send_packet: delay=-182673
[   75.977833] ccid3_hc_tx_send_packet: delay=-182778
[   75.977942] ccid3_hc_tx_send_packet: delay=-182828
[   75.978032] ccid3_hc_tx_send_packet: delay=-182859
[   75.978145] ccid3_hc_tx_send_packet: delay=-182914
[   75.978265] ccid3_hc_tx_send_packet: delay=-182975
[   75.978396] ccid3_hc_tx_send_packet: delay=-183048
[   75.978549] ccid3_hc_tx_send_packet: delay=-183141
[   75.978690] ccid3_hc_tx_send_packet: delay=-183223
[   75.978748] ccid3_hc_tx_send_packet: delay=-183223
[   75.978863] ccid3_hc_tx_send_packet: delay=-183279
[   75.979098] ccid3_hc_tx_send_packet: delay=-183455
[   75.979102] ccid3_hc_tx_update_win_count: now at 0X1
[   75.979139] ccid3_hc_tx_send_packet: delay=-183435
[   75.979304] ccid3_hc_tx_send_packet: delay=-183544
[   75.979349] ccid3_hc_tx_send_packet: delay=-183530
[   75.979457] ccid3_hc_tx_send_packet: delay=-183579
[   75.979601] ccid3_hc_tx_send_packet: delay=-183664
[   75.979701] ccid3_hc_tx_send_packet: delay=-183705
[   75.979881] ccid3_hc_tx_send_packet: delay=-183827
[   75.979941] ccid3_hc_tx_send_packet: delay=-183828
[   75.980067] ccid3_hc_tx_send_packet: delay=-183895
[   75.980219] ccid3_hc_tx_send_packet: delay=-183988
[   75.980308] dccp_v4_rcv:      ACK src9.133.209.65@5001  dst9.133.209.75@33438 seq4797824709, ack 51985877
[   75.980316] ccid3_hc_tx_parse_options: client(f651c080), RECEIVE_RATE784088
[   75.980320] ccid3_hc_tx_parse_options: client(f651c080), LOSS_EVENT_RATEB94967295
[   75.980324] dccp_parse_options: client rx opt: TIMESTAMP6585, ackno 51985877
[   75.980327] dccp_parse_options: client rx opt: NDP count9
[   75.980333] ccid3_hc_tx_packet_recv: client(f651c080), RTTS80us (sampleT83us), s15, p=0, X_calc=0, X_recv784088, X#839284
[   75.980436] ccid3_hc_tx_send_packet: delay=-184147
[   75.980471] ccid3_hc_tx_send_packet: delay=-184123
[   75.980477] ccid3_hc_tx_update_win_count: now at 0X2
[   75.980671] ccid3_hc_tx_send_packet: delay=-184263
[   75.980710] ccid3_hc_tx_send_packet: delay=-184241
[   75.980779] ccid3_hc_tx_send_packet: delay=-184254
[   75.980945] ccid3_hc_tx_send_packet: delay=-184361
[   75.981063] ccid3_hc_tx_send_packet: delay=-184421
[   75.981138] ccid3_hc_tx_send_packet: delay=-184436
[   75.981257] ccid3_hc_tx_send_packet: delay=-184497
[   75.981378] ccid3_hc_tx_send_packet: delay=-184559
[   75.981527] ccid3_hc_tx_send_packet: delay=-184650
[   75.981662] ccid3_hc_tx_send_packet: delay=-184726
[   75.981734] ccid3_hc_tx_send_packet: delay=-184739
[   75.981860] ccid3_hc_tx_send_packet: delay=-184805
[   75.981863] ccid3_hc_tx_update_win_count: now at 0X3
[   75.981992] ccid3_hc_tx_send_packet: delay=-184879
[   75.982208] ccid3_hc_tx_send_packet: delay=-185036
[   75.982246] ccid3_hc_tx_send_packet: delay=-185013
[   75.982425] ccid3_hc_tx_send_packet: delay=-185136
[   75.982472] ccid3_hc_tx_send_packet: delay=-185123
[   75.982574] ccid3_hc_tx_send_packet: delay=-185167
[   75.982716] ccid3_hc_tx_send_packet: delay=-185251
[   75.982814] ccid3_hc_tx_send_packet: delay=-185290
[   75.982996] cc ccid3_hc_tx_send_ ccid3_hc_tx_send_packet: delay=-243593
[   76.097573] ccid3_hc_tx_send_packet: delay=-243658
[   76.097689] ccid3_hc_tx_send_packet: delay=-243715
[   76.097810] ccid3_hc_tx_send_packet: delay=-243778
[   76.098044] ccid3_hc_tx_send_packet: delay=-243952
[   76.098047] ccid3_hc_tx_update_win_count: now at 0X4
[   76.098085] ccid3_hc_tx_send_packet: delay=-243934
[   76.098167] ccid3_hc_tx_send_packet: delay=-243958
[   76.098321] ccid3_hc_tx_send_packet: delay=-244053
[   76.098426] ccid3_hc_tx_send_packet: delay=-244100
[   76.098530] ccid3_hc_tx_send_packet: delay=-244145
[   76.098649] ccid3_hc_tx_send_packet: delay=-244205
[   76.098768] ccid3_hc_tx_send_packet: delay=-244265
[   76.098914] ccid3_hc_tx_send_packet: delay=-244352
[   76.099004] ccid3_hc_tx_send_packet: delay=-244384
[   76.099122] ccid3_hc_tx_send_packet: delay=-244442
[   76.099308] ccid3_hc_tx_send_packet: delay=-244570
[   76.099367] ccid3_hc_tx_send_packet: delay=-244570
[   76.099536] ccid3_hc_tx_send_packet: delay=-244680
[   76.099539] ccid3_hc_tx_update_win_count: now at 0X5
[   76.099607] ccid3_hc_tx_send_packet: delay=-244692
[   76.099871] dccp_v4_rcv:      ACK src9.133.209.65@5001  dst9.133.209.75@33438 seq4797824731, ack 51986876
[   76.099880] ccid3_hc_tx_parse_options: client(f651c080), RECEIVE_RATE886477
[   76.099884] ccid3_hc_tx_parse_options: client(f651c080), LOSS_EVENT_RATEB94967295
[   76.099888] dccp_parse_options: client rx opt: TIMESTAMP8557, ackno 51986876
[   76.099891] dccp_parse_options: client rx opt: NDP count1
[   76.099896] ccid3_hc_tx_update_x: X_prev#754850, X_now#772954, X_calc=0, X_recv886477
[   76.099900] ccid3_update_send_interval: t_ipiY, delta), s15, X#772954
[   76.099905] ccid3_hc_tx_packet_recv: client(f651c080), RTTT54us (sampleU53us), s15, p=0, X_calc=0, X_recv886477, X#772954
[   76.099932] ccid3_hc_tx_send_packet: delay=-244959
[   76.099979] ccid3_hc_tx_send_packet: delay=-244947
[   76.100020] ccid3_hc_tx_send_packet: delay=-244926
[   76.100087] ccid3_hc_tx_send_packet: delay=-244937
[   76.100244] ccid3_hc_tx_send_packet: delay=-245036
[   76.100351] ccid3_hc_tx_send_packet: delay=-245083
[   76.100445] ccid3_hc_tx_send_packet: delay=-245118
[   76.100564] ccid3_hc_tx_send_packet: delay=-245179
[   76.100767] ccid3_hc_tx_send_packet: delay=-245323
[   76.100819] ccid3_hc_tx_send_packet: delay=-245316
[   76.100954] ccid3_hc_tx_send_packet: delay=-245393
[   76.100958] ccid3_hc_tx_update_win_count: now at 0X6
[   76.101105] ccid3_hc_tx_send_packet: delay=-245484
[   76.101163] ccid3_hc_tx_send_packet: delay=-245484
[   76.101285] ccid3_hc_tx_send_packet: delay=-245547
[   76.101478] ccid3_hc_tx_send_packet: delay=-245681
[   76.101526] ccid3_hc_tx_send_packet: delay=-245670
[   76.101701] ccid3_hc_tx_send_packet: delay=-245787
[   76.101762] ccid3_hc_tx_send_packet: delay=-245788
[   76.101882] ccid3_hc_tx_send_packet: delay=-245850
[   76.102012] ccid3_hc_tx_send_packet: delay=-245921
[   76.102121] ccid3_hc_tx_send_packet: delay=-245971
[   76.102274] ccid3_hc_tx_send_packet: delay=-246065
[   76.102424] ccid3_hc_tx_send_packet: delay=-246157
[   76.102428] ccid3_hc_tx_update_win_count: now at 0X7
[   76.102479] ccid3_hc_tx_send_packet: delay=-246153
[   76.102608] ccid3_hc_tx_send_packet: delay=-246224
[   76.102764] ccid3_hc_tx_send_packet: delay=-246320
[   76.102960] ccid3_hc_tx_send_packet: delay=-246458
[   76.103000] ccid3_hc_tx_send_packet: delay=-246438
[   76.103174] ccid3_hc_tx_send_packet: delay=-246554
[   76.103226] ccid3_hc_tx_send_packet: delay=-246548
[   76.103313] ccid3_hc_tx_send_packet: delay=-246576
[   76.103432] ccid3_hc_tx_send_packet: delay=-246636
[   76.103552] ccid3_hc_tx_send_packet: del6346] ccid3_hc_tx_send_packet: delay=-298981
[   76.206493] ccid3_hc_tx_send_packet: delay=-299069
[   76.206497] ccid3_hc_tx_update_win_count: now at 0X0
[   76.206585] ccid3_hc_tx_send_packet: delay=-299101
[   76.206732] ccid3_hc_tx_send_packet: delay=-299190
[   76.206823] ccid3_hc_tx_send_packet: delay=-299222
[   76.207022] ccid3_hc_tx_send_packet: delay=-299363
[   76.207061] ccid3_hc_tx_send_packet: delay=-299343
[   76.207236] ccid3_hc_tx_send_packet: delay=-299459
[   76.207352] ccid3_hc_tx_send_packet: delay=-299516
[   76.207440] ccid3_hc_tx_send_packet: delay=-299546
[   76.207577] ccid3_hc_tx_send_packet: delay=-299624
[   76.207721] ccid3_hc_tx_send_packet: delay=-299709
[   76.207798] ccid3_hc_tx_send_packet: delay=-299727
[   76.207969] ccid3_hc_tx_send_packet: delay=-299839
[   76.207972] ccid3_hc_tx_update_win_count: now at 0X1
[   76.208055] ccid3_hc_tx_send_packet: delay=-299866
[   76.208206] ccid3_hc_tx_send_packet: delay=-299959
[   76.208280] ccid3_hc_tx_send_packet: delay=-299973
[   76.208447] ccid3_hc_tx_send_packet: delay=-300082
[   76.208521] ccid3_hc_tx_send_packet: delay=-300097
[   76.208687] ccid3_hc_tx_send_packet: delay=-300204
[   76.208752] dccp_v4_rcv:      ACK src9.133.209.65@5001  dst9.133.209.75@33438 seq4797824751, ack 51987786
[   76.208760] ccid3_hc_tx_parse_options: client(f651c080), RECEIVE_RATE883889
[   76.208764] ccid3_hc_tx_parse_options: client(f651c080), LOSS_EVENT_RATEB94967295
[   76.208768] dccp_parse_options: client rx opt: TIMESTAMP9465, ackno 51987786
[   76.208771] dccp_parse_options: client rx opt: NDP count1
[   76.208776] ccid3_hc_tx_update_x: X_prev#815306, X_now#767778, X_calc=0, X_recv883889
[   76.208780] ccid3_update_send_interval: t_ipiY, delta), s15, X#767778
[   76.208785] ccid3_hc_tx_packet_recv: client(f651c080), RTTT42us (sampleT55us), s15, p=0, X_calc=0, X_recv883889, X#767778
[   76.208979] ccid3_hc_tx_send_packet: delay=-300438
[   76.209022] ccid3_hc_tx_send_packet: delay=-300422
[   76.209055] ccid3_hc_tx_send_packet: delay=-300396
[   76.209243] ccid3_hc_tx_send_packet: delay=-300525
