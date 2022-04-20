commit 8ca5b4b6aaf87a4d6c7167905dfe39987eddf04c
Author: chocovore17 <maelle.guerre@gmail.com>
Date:   Sat Mar 12 10:00:29 2022 +0000

    cache model designed and debugged but quesasim not

commit f8ef54f777536cc7c47b391fa5f6e122a925ed5a
Author: chocovore17 <maelle.guerre@gmail.com>
Date:   Fri Mar 11 16:44:42 2022 +0000

    tested cache works on the surface

commit 919e18731cb8c788e7dc0fad2364bd11ed0f69ac
Author: chocovore17 <maelle.guerre@gmail.com>
Date:   Fri Mar 11 15:26:14 2022 +0000

    added cache but problems with tag bounds.Downstream works. TODO: change testbench for better test, fix tag bounds, questasim gui

commit 8269db3284bc919f2c6adce6bdae39527c772ca9
Author: chocovore17 <maelle.guerre@gmail.com>
Date:   Fri Mar 11 13:39:50 2022 +0000

    both memory models unclocked

commit 34b8cb36f65a892587845c9eb258c6e6e4f13ef5
Author: chocovore17 <maelle.guerre@gmail.com>
Date:   Fri Mar 11 13:37:33 2022 +0000

    both memory models unclocked

commit 4e66eeccad6a463ff810413f7a8f9afad1112fa7
Author: chocovore17 <maelle.guerre@gmail.com>
Date:   Fri Mar 11 13:20:27 2022 +0000

    top level has new memory

commit 31a3403e8d722a3c7b0497f7b348a7289b9cbada
Author: chocovore17 <maelle.guerre@gmail.com>
Date:   Thu Mar 10 15:35:36 2022 +0000

    uncloced memory

commit e949694e820080f04af3a87d85ab0b59904108bd
Author: chocovore17 <maelle.guerre@gmail.com>
Date:   Thu Mar 10 10:37:40 2022 +0000

    top level works

commit d7824c9215e2e2da62e2c8b582c3ef3dd465437a
Merge: e2a3a14 bc02f9b
Author: chocovore17 <maelle.guerre@gmail.com>
Date:   Thu Mar 10 10:36:50 2022 +0000

    Merge branch 'memorydev' of https://github.com/chocovore17/fpga-caching-fyp into memorydev
    
    Conflicts:
    	code/downstream/downstream_top_reset.sv
    	code/upstream/up
    	code/upstream/upstream.sv
    	code/upstream/upstream_top_reset.sv
    	models/clockedmemory/code/downstream/downstreamtop
    	models/clockedmemory/code/downstream/getack
    	models/clockedmemory/code/downstream/top
    	models/clockedmemory/code/downstream/top-Wall
    	models/clockedmemory/code/downstream/toptest
    	testbench/outputs/upstream/UPSTREAM_sim.txt
    	testbench/tbenchoutputs/upstream/upstreamdump.vcd
    	work/_info
    	work/_lib.qdb
    	work/seg_work_opt/_lib.qdb
    	work/seg_work_opt/_lib1_0.qdb
    	work/seg_work_opt/_lib1_0.qtl
    	work/seg_work_opt/_lib2_0.qdb
    	work/seg_work_opt/_lib2_0.qtl
    	work/seg_work_opt/_lib3_0.qdb
    	work/seg_work_opt/_lib3_0.qtl
    	work/seg_work_opt/_lib4_0.qdb
    	work/seg_work_opt/_lib4_0.qpg
    	work/seg_work_opt/_lib4_0.qtl
    	work/seg_work_opt/_lib5_0.qdb
    	work/seg_work_opt/_lib5_0.qpg
    	work/seg_work_opt/_lib5_0.qtl

commit e2a3a14cf019ccbe9ff8dd43e7df9cafbaa85e68
Author: chocovore17 <maelle.guerre@gmail.com>
Date:   Thu Mar 10 10:34:53 2022 +0000

    merge

commit 4d44dad37d82f27ebcf97b53cdff456fa3d3f356
Author: chocovore17 <maelle.guerre@gmail.com>
Date:   Thu Mar 10 10:33:05 2022 +0000

    merge

commit b5fcc3aa6a3b84d4001266faf25b11926ec4dd5a
Author: chocovore17 <maelle.guerre@gmail.com>
Date:   Thu Mar 10 10:30:40 2022 +0000

    new

commit c27a353f731b3af0b537516ef3469169c39f22ee
Author: chocovore17 <maelle.guerre@gmail.com>
Date:   Thu Mar 10 10:28:08 2022 +0000

    top level works, very basic to improve

commit bc02f9b52ac1598549334ef92f6b5dde23eb862d
Merge: 542a773 550c37d
Author: chocovore17 <47193844+chocovore17@users.noreply.github.com>
Date:   Thu Mar 10 09:54:37 2022 +0000

    Merge remote-tracking branch 'origin/main' into memorydev

commit 542a773696bda06ec02cfbbe158ea9f43ced1fbb
Author: chocovore17 <47193844+chocovore17@users.noreply.github.com>
Date:   Thu Mar 10 09:51:59 2022 +0000

    on main. Upstream and downstream first version works and test

commit 7068028570f14e9e6929257cfd4562fd78ed41b9
Merge: b6daa0c e178087
Author: chocovore17 <maelle.guerre@gmail.com>
Date:   Thu Mar 10 09:46:09 2022 +0000

    Merge branch 'memorydev' of https://github.com/chocovore17/fpga-caching-fyp into memorydev
    
    Conflicts:
    	.vscode/settings.json
    	Documentation/IMG_20220201_101527.jpg
    	Documentation/IMG_20220201_102336.jpg
    	Documentation/IMG_20220201_102736.jpg
    	Documentation/IMG_20220201_102738.jpg
    	Documentation/Yousin-Maelle.docx
    	Documentation/project description/toplevell.drawio
    	Documentation/toplevell.drawio.png
    	Documentation/upstreamstatemachinediagram.PNG
    	code/upstream/upstream.sv
    	code/upstream/upstream_top.sv
    	shared/ramupstream.sv
    	testbench/Module/toptest.sv
    	testbench/outputs/upstream/UPSTREAM_sim.txt
    	testbench/tbenchoutputs/upstream/upstreamdump.vcd
    	testbench/unit_level/UPSTREAM/driver_UPSTREAM.sv
    	testbench/unit_level/UPSTREAM/interface_UPSTREAM.sv
    	testbench/unit_level/UPSTREAM/monitor_UPSTREAM.sv
    	testbench/unit_level/UPSTREAM/tb_top_UPSTREAM.sv
    	testbench/unit_level/UPSTREAM/transaction_UPSTREAM.sv
    	work/_info
    	work/_lib.qdb
    	work/seg_work_opt/_lib.qdb
    	work/seg_work_opt/_lib1_0.qdb
    	work/seg_work_opt/_lib1_0.qtl
    	work/seg_work_opt/_lib2_0.qdb
    	work/seg_work_opt/_lib2_0.qtl
    	work/seg_work_opt/_lib3_0.qdb
    	work/seg_work_opt/_lib3_0.qtl
    	work/seg_work_opt/_lib4_0.qdb
    	work/seg_work_opt/_lib4_0.qpg
    	work/seg_work_opt/_lib4_0.qtl
    	work/seg_work_opt/_lib5_0.qdb
    	work/seg_work_opt/_lib5_0.qpg
    	work/seg_work_opt/_lib5_0.qtl

commit b6daa0c4289006f4090fba8ad6ef92fa909e4545
Author: chocovore17 <maelle.guerre@gmail.com>
Date:   Thu Mar 10 09:43:49 2022 +0000

    should fix merge

commit ecfd7507d9584d337ac564960edda66ca694b6af
Author: chocovore17 <maelle.guerre@gmail.com>
Date:   Thu Mar 10 09:41:33 2022 +0000

    merge changes

commit ffbf11818828fb177535ca270bece7adddb3dc74
Author: chocovore17 <maelle.guerre@gmail.com>
Date:   Thu Mar 10 09:36:00 2022 +0000

    upstream testbench and upstream debugged

commit 550c37d2bb2fbbcde99aac695c2fd4f2081b3bdf
Merge: 6fa09bf b19a9e7
Author: chocovore17 <47193844+chocovore17@users.noreply.github.com>
Date:   Thu Mar 10 08:38:13 2022 +0000

    Merge branch 'main' of https://github.com/chocovore17/fpga-caching-fyp into main

commit e1780877ef5757b3f0a3f9b814f2c79e95136ebe
Merge: 80bf3fb 6fa09bf
Author: chocovore17 <47193844+chocovore17@users.noreply.github.com>
Date:   Thu Mar 10 08:34:22 2022 +0000

    Merge branch 'main' into memorydev

commit 80bf3fb6e3c30868d91bf85a546a9368be24308f
Author: chocovore17 <47193844+chocovore17@users.noreply.github.com>
Date:   Thu Mar 10 08:33:30 2022 +0000

    test

commit 6fa09bf747da37c26e479552a4d01177bba83fd2
Author: chocovore17 <47193844+chocovore17@users.noreply.github.com>
Date:   Thu Mar 10 08:30:43 2022 +0000

    idc2

commit b9416149fbfc71e1d6d0596de6a363aff73bdc03
Author: chocovore17 <47193844+chocovore17@users.noreply.github.com>
Date:   Thu Mar 10 08:29:24 2022 +0000

    idc

commit 8afc9fa3b5a037725ae84cca3bf18aa5a399990a
Author: chocovore17 <maelle.guerre@gmail.com>
Date:   Thu Mar 10 08:17:20 2022 +0000

    downstream tb works, downstream behaves as expected, double clock in test

commit 53b153c84d5389382ec691aaa65d58dc99ff3d2f
Author: chocovore17 <maelle.guerre@gmail.com>
Date:   Wed Mar 9 19:02:24 2022 +0000

    deleted useless stuff

commit 2286b0037b2bdf0f7a6aca6014675a3907e5e675
Author: chocovore17 <maelle.guerre@gmail.com>
Date:   Wed Mar 9 18:51:04 2022 +0000

    plz work

commit 60c19c4d46fb5db0369ed030a2c7ad4141e3f280
Author: Maelle L Guerre <mlg18@ee-mill3.ee.ic.ac.uk>
Date:   Wed Mar 9 18:16:48 2022 +0000

    tbench works, need to change clocks

commit 8a8378ff009a1e1a12a7669e2f79ffaeac7b100f
Author: Maelle L Guerre <mlg18@ee-mill3.ee.ic.ac.uk>
Date:   Tue Mar 8 15:22:29 2022 +0000

    downstream testbench works

commit b19a9e743315190f4804cabd9d44a00ef97e05a1
Author: chocovore17 <47193844+chocovore17@users.noreply.github.com>
Date:   Thu Feb 10 15:26:58 2022 +0000

    main changes of baseline done

commit 8fdeeb37a62e9d5dd98497d3c4bb6af94f653b3e
Author: chocovore17 <47193844+chocovore17@users.noreply.github.com>
Date:   Thu Feb 10 11:30:50 2022 +0000

    reset

commit 221fb918a7c94f2d83fa22198d5d942745e81e6f
Author: chocovore17 <47193844+chocovore17@users.noreply.github.com>
Date:   Tue Jan 18 10:08:22 2022 +0000

    test downstream

commit 1a3abbb53226dd76fc17c366ee2973a62df208de
Author: chocovore17 <47193844+chocovore17@users.noreply.github.com>
Date:   Fri Dec 31 17:22:58 2021 +0000

    todos

commit 1d2ccc2d897a4d5fa0fa63cf95d7a75a61f7cfdc
Author: chocovore17 <maelle.guerre18@imperial.ac.uk>
Date:   Thu Nov 25 16:24:14 2021 +0000

    baseline model working

commit 75e22e453752d2bd9dfea22f74bd5594fb121f3f
Author: chocovore17 <maelle.guerre18@imperial.ac.uk>
Date:   Tue Nov 23 15:06:02 2021 +0000

    top level module written

commit 88ae340372cb33d9858e4238240ec14372ceaa43
Author: chocovore17 <maelle.guerre18@imperial.ac.uk>
Date:   Tue Nov 23 14:41:00 2021 +0000

    rams changed to 16 bits, tested and accumulate for writing

commit 98b69e9f44ce7614bcd7d60c5ac308bcc221899d
Author: chocovore17 <maelle.guerre18@imperial.ac.uk>
Date:   Tue Nov 23 12:15:16 2021 +0000

    downstream top ok, upstream top not

commit 88c5f65d5ea56ced59ddf27c707717a2733a9d0c
Author: chocovore17 <47193844+chocovore17@users.noreply.github.com>
Date:   Sat Nov 20 15:09:18 2021 +0000

    Add files via upload

commit 3bae9902ed8c513c70b80ce054cb4bc8218dbe09
Author: chocovore17 <47193844+chocovore17@users.noreply.github.com>
Date:   Wed Nov 17 17:36:00 2021 +0000

    downstream can store accumulated cancelled orders!

commit 1c70846ca891f97a9c71f2cfdc4326a1ac6d0a8b
Author: chocovore17 <47193844+chocovore17@users.noreply.github.com>
Date:   Fri Nov 12 16:05:58 2021 +0000

    automatic clock in top level

commit 6ef7f61ef2657b672ae4e2f3539b02db67861e4c
Author: chocovore17 <47193844+chocovore17@users.noreply.github.com>
Date:   Fri Nov 12 13:57:17 2021 +0000

    everything written. top modules fail test why?

commit 42c53ceb04491e9a243ab76660b0a6d3514ff3ff
Author: chocovore17 <47193844+chocovore17@users.noreply.github.com>
Date:   Fri Nov 12 12:29:31 2021 +0000

    tested all upstream modules, wrote upstreram top module

commit eccaa67cff718349d9c86504119b146c367ec38b
Author: chocovore17 <47193844+chocovore17@users.noreply.github.com>
Date:   Thu Nov 11 16:23:58 2021 +0000

    testbench & outputs

commit 4415c17fd0f1363c9f7621380826088f828e4c7e
Author: chocovore17 <47193844+chocovore17@users.noreply.github.com>
Date:   Thu Nov 11 16:22:44 2021 +0000

    Memory works !

commit a1f436929cf0e2d2a8b06b5c94c675e62b2a417c
Author: chocovore17 <47193844+chocovore17@users.noreply.github.com>
Date:   Thu Nov 11 15:53:32 2021 +0000

    test & working downstream, SLT

commit 528539fc981437a5cc05afcce60a550011532846
Author: chocovore17 <47193844+chocovore17@users.noreply.github.com>
Date:   Tue Nov 9 13:10:25 2021 +0000

    added some ram

commit 737ec1cbe23fab56eff135552d71e386469945dc
Author: chocovore17 <47193844+chocovore17@users.noreply.github.com>
Date:   Sat Nov 6 18:27:29 2021 +0000

    documentation

commit 5d634b23a377c45e01bb1267595649a4d255ee8f
Author: chocovore17 <47193844+chocovore17@users.noreply.github.com>
Date:   Sat Nov 6 18:22:12 2021 +0000

    README links

commit 7abd2f46529ceec9d82a46aaa05d827b7a6d73c4
Author: chocovore17 <47193844+chocovore17@users.noreply.github.com>
Date:   Sat Nov 6 18:21:10 2021 +0000

    README, upstream processor updated

commit 4d9480a614b0bfddfc43e96021d31adc8e5c13bb
Author: chocovore17 <47193844+chocovore17@users.noreply.github.com>
Date:   Sat Nov 6 17:54:06 2021 +0000

    rsk check , SLT logic framework

commit 86127a032ccf9675871585a7ea1994cb4ae070d0
Author: chocovore17 <47193844+chocovore17@users.noreply.github.com>
Date:   Sat Nov 6 17:15:53 2021 +0000

    downstream processor code + testbench

commit 8193f200434df2cd548d742d5ab8ed4cd3117992
Author: chocovore17 <47193844+chocovore17@users.noreply.github.com>
Date:   Sat Nov 6 16:26:51 2021 +0000

    Initial commit
