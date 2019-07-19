
	.sect "codestart"
3f8bb2:              code_start:
3f8bb2:              codestart:
003f8bb2   007f       LB           0x3f8b80
003f8bb3   8b80

	.sect ".text"
3f8000:              _main:
003f8000   fe0c       ADDB         SP, #12
003f8001   9a0a       MOVB         AL, #0xa
003f8002   9b00       MOVB         AH, #0x0
003f8003   767f       LCR          0x3f84e8
003f8004   84e8
003f8005   284c       MOV          *-SP[12], #0xabcd
003f8006   abcd
003f8007   767f       LCR          0x3f8493
003f8008   8493
003f8009   9649       MOV          *-SP[9], AL
003f800a   5200       CMPB         AL, #0x0
003f800b   ec07       SBF          7, EQ
003f800c   0222       MOVB         ACC, #34
003f800d   761f       MOVW         DP, #0x1bf
003f800e   01bf
003f800f   284c       MOV          *-SP[12], #0xee01
003f8010   ee01
003f8011   1e04       MOVL         @0x4, ACC
003f8012   767f       LCR          0x3f8518
003f8013   8518
003f8014   767f       LCR          0x3f84bb
003f8015   84bb
003f8016   761f       MOVW         DP, #0xfe45
003f8017   fe45
003f8018   ff2f       MOV          ACC, #0x280 << 15
003f8019   0280
003f801a   1e02       MOVL         @0x2, ACC
003f801b   761f       MOVW         DP, #0xfe45
003f801c   fe45
003f801d   0200       MOVB         ACC, #0
003f801e   1e00       MOVL         @0x0, ACC
003f801f   767f       LCR          0x3f835f
003f8020   835f
003f8021   9649       MOV          *-SP[9], AL
003f8022   5200       CMPB         AL, #0x0
003f8023   ec07       SBF          7, EQ
003f8024   0222       MOVB         ACC, #34
003f8025   761f       MOVW         DP, #0x1bf
003f8026   01bf
003f8027   284c       MOV          *-SP[12], #0xee02
003f8028   ee02
003f8029   1e04       MOVL         @0x4, ACC
003f802a   8f3e       MOVL         XAR4, #0x3e8000
003f802b   8000
003f802c   0200       MOVB         ACC, #0
003f802d   a844       MOVL         *-SP[4], XAR4
003f802e   56bf       MOVB         *-SP[10], #0x01, UNC
003f802f   014a
003f8030   1e46       MOVL         *-SP[6], ACC
003f8031   8f01       MOVL         XAR4, #0x010000
003f8032   0000
003f8033   a8a9       MOVL         ACC, XAR4
003f8034   0f46       CMPL         ACC, *-SP[6]
003f8035   6911       SB           17, LOS
003f8036   8a44       MOVL         XAR4, *-SP[4]
003f8037   9284       MOV          AL, *XAR4++
003f8038   9642       MOV          *-SP[2], AL
003f8039   1ba9       CMP          AL, #-1
003f803a   ffff
003f803b   a844       MOVL         *-SP[4], XAR4
003f803c   ec02       SBF          2, EQ
003f803d   2b4a       MOV          *-SP[10], #0
003f803e   0201       MOVB         ACC, #1
003f803f   8f01       MOVL         XAR4, #0x010000
003f8040   0000
003f8041   0746       ADDL         ACC, *-SP[6]
003f8042   1e46       MOVL         *-SP[6], ACC
003f8043   a8a9       MOVL         ACC, XAR4
003f8044   0f46       CMPL         ACC, *-SP[6]
003f8045   66f1       SB           -15, HI
003f8046   0200       MOVB         ACC, #0
003f8047   8f3d       MOVL         XAR4, #0x3d7800
003f8048   7800
003f8049   56bf       MOVB         *-SP[11], #0x01, UNC
003f804a   014b
003f804b   1e46       MOVL         *-SP[6], ACC
003f804c   a844       MOVL         *-SP[4], XAR4
003f804d   ff20       MOV          ACC, #1024
003f804e   0400
003f804f   0f46       CMPL         ACC, *-SP[6]
003f8050   6910       SB           16, LOS
003f8051   8a44       MOVL         XAR4, *-SP[4]
003f8052   9284       MOV          AL, *XAR4++
003f8053   9642       MOV          *-SP[2], AL
003f8054   1ba9       CMP          AL, #-1
003f8055   ffff
003f8056   a844       MOVL         *-SP[4], XAR4
003f8057   ec02       SBF          2, EQ
003f8058   2b4b       MOV          *-SP[11], #0
003f8059   0201       MOVB         ACC, #1
003f805a   0746       ADDL         ACC, *-SP[6]
003f805b   1e46       MOVL         *-SP[6], ACC
003f805c   ff20       MOV          ACC, #1024
003f805d   0400
003f805e   0f46       CMPL         ACC, *-SP[6]
003f805f   66f2       SB           -14, HI
003f8060   0220       MOVB         ACC, #32
003f8061   761f       MOVW         DP, #0x1bf
003f8062   01bf
003f8063   284c       MOV          *-SP[12], #0xabcd
003f8064   abcd
003f8065   1e02       MOVL         @0x2, ACC
003f8066   0202       MOVB         ACC, #2
003f8067   1e04       MOVL         @0x4, ACC
003f8068   767f       LCR          0x3f82b0
003f8069   82b0
003f806a   761f       MOVW         DP, #0x1bf
003f806b   01bf
003f806c   9641       MOV          *-SP[1], AL
003f806d   0222       MOVB         ACC, #34
003f806e   1e02       MOVL         @0x2, ACC
003f806f   ffef       B            406, UNC
003f8070   0196
003f8071   0220       MOVB         ACC, #32
003f8072   1e02       MOVL         @0x2, ACC
003f8073   0202       MOVB         ACC, #2
003f8074   1e04       MOVL         @0x4, ACC
003f8075   767f       LCR          0x3f82f5
003f8076   82f5
003f8077   924c       MOV          AL, *-SP[12]
003f8078   767f       LCR          0x3f8310
003f8079   8310
003f807a   284c       MOV          *-SP[12], #0xabcd
003f807b   abcd
003f807c   6f23       SB           35, UNC
003f807d   284c       MOV          *-SP[12], #0xabcd
003f807e   abcd
003f807f   767f       LCR          0x3f82f5
003f8080   82f5
003f8081   8f3e       MOVL         XAR4, #0x3e8000
003f8082   8000
003f8083   0200       MOVB         ACC, #0
003f8084   a844       MOVL         *-SP[4], XAR4
003f8085   1e46       MOVL         *-SP[6], ACC
003f8086   8f01       MOVL         XAR4, #0x010000
003f8087   0000
003f8088   a8a9       MOVL         ACC, XAR4
003f8089   0f46       CMPL         ACC, *-SP[6]
003f808a   690f       SB           15, LOS
003f808b   8a44       MOVL         XAR4, *-SP[4]
003f808c   9284       MOV          AL, *XAR4++
003f808d   9642       MOV          *-SP[2], AL
003f808e   a844       MOVL         *-SP[4], XAR4
003f808f   767f       LCR          0x3f8310
003f8090   8310
003f8091   0201       MOVB         ACC, #1
003f8092   8f01       MOVL         XAR4, #0x010000
003f8093   0000
003f8094   0746       ADDL         ACC, *-SP[6]
003f8095   1e46       MOVL         *-SP[6], ACC
003f8096   a8a9       MOVL         ACC, XAR4
003f8097   0f46       CMPL         ACC, *-SP[6]
003f8098   66f3       SB           -13, HI
003f8099   0220       MOVB         ACC, #32
003f809a   761f       MOVW         DP, #0x1bf
003f809b   01bf
003f809c   1e02       MOVL         @0x2, ACC
003f809d   0202       MOVB         ACC, #2
003f809e   1e04       MOVL         @0x4, ACC
003f809f   767f       LCR          0x3f834c
003f80a0   834c
003f80a1   6fc7       SB           -57, UNC
003f80a2   767f       LCR          0x3f82f5
003f80a3   82f5
003f80a4   924a       MOV          AL, *-SP[10]
003f80a5   5201       CMPB         AL, #0x1
003f80a6   ed23       SBF          35, NEQ
003f80a7   767f       LCR          0x3f837e
003f80a8   837e
003f80a9   9649       MOV          *-SP[9], AL
003f80aa   767f       LCR          0x3f82b0
003f80ab   82b0
003f80ac   8f3e       MOVL         XAR4, #0x3e8000
003f80ad   8000
003f80ae   0ea9       MOVU         ACC, AL
003f80af   a844       MOVL         *-SP[4], XAR4
003f80b0   1e48       MOVL         *-SP[8], ACC
003f80b1   8f01       MOVL         XAR4, #0x010000
003f80b2   0000
003f80b3   0200       MOVB         ACC, #0
003f80b4   1e46       MOVL         *-SP[6], ACC
003f80b5   a8a9       MOVL         ACC, XAR4
003f80b6   0f46       CMPL         ACC, *-SP[6]
003f80b7   690d       SB           13, LOS
003f80b8   8a44       MOVL         XAR4, *-SP[4]
003f80b9   9284       MOV          AL, *XAR4++
003f80ba   7242       ADD          *-SP[2], AL
003f80bb   0201       MOVB         ACC, #1
003f80bc   a844       MOVL         *-SP[4], XAR4
003f80bd   0746       ADDL         ACC, *-SP[6]
003f80be   1e46       MOVL         *-SP[6], ACC
003f80bf   8f01       MOVL         XAR4, #0x010000
003f80c0   0000
003f80c1   a8a9       MOVL         ACC, XAR4
003f80c2   0f46       CMPL         ACC, *-SP[6]
003f80c3   66f5       SB           -11, HI
003f80c4   9249       MOV          AL, *-SP[9]
003f80c5   56c0       BF           271, NEQ
003f80c6   010f
003f80c7   ffef       B            258, UNC
003f80c8   0102
003f80c9   0200       MOVB         ACC, #0
003f80ca   8f01       MOVL         XAR4, #0x010001
003f80cb   0001
003f80cc   1e46       MOVL         *-SP[6], ACC
003f80cd   a8a9       MOVL         ACC, XAR4
003f80ce   0f46       CMPL         ACC, *-SP[6]
003f80cf   ffe9       B            168, LOS
003f80d0   00a8
003f80d1   767f       LCR          0x3f8256
003f80d2   8256
003f80d3   8f01       MOVL         XAR4, #0x010001
003f80d4   0001
003f80d5   9642       MOV          *-SP[2], AL
003f80d6   0201       MOVB         ACC, #1
003f80d7   0746       ADDL         ACC, *-SP[6]
003f80d8   1e46       MOVL         *-SP[6], ACC
003f80d9   a8a9       MOVL         ACC, XAR4
003f80da   0f46       CMPL         ACC, *-SP[6]
003f80db   66f6       SB           -10, HI
003f80dc   ffef       B            155, UNC
003f80dd   009b
003f80de   2b49       MOV          *-SP[9], #0
003f80df   767f       LCR          0x3f82f5
003f80e0   82f5
003f80e1   767f       LCR          0x3f83b3
003f80e2   83b3
003f80e3   9649       MOV          *-SP[9], AL
003f80e4   767f       LCR          0x3f82b0
003f80e5   82b0
003f80e6   8f3e       MOVL         XAR4, #0x3e8000
003f80e7   8000
003f80e8   0ea9       MOVU         ACC, AL
003f80e9   a844       MOVL         *-SP[4], XAR4
003f80ea   1e48       MOVL         *-SP[8], ACC
003f80eb   8f01       MOVL         XAR4, #0x010000
003f80ec   0000
003f80ed   0200       MOVB         ACC, #0
003f80ee   1e46       MOVL         *-SP[6], ACC
003f80ef   a8a9       MOVL         ACC, XAR4
003f80f0   0f46       CMPL         ACC, *-SP[6]
003f80f1   690d       SB           13, LOS
003f80f2   8a44       MOVL         XAR4, *-SP[4]
003f80f3   9284       MOV          AL, *XAR4++
003f80f4   7242       ADD          *-SP[2], AL
003f80f5   0201       MOVB         ACC, #1
003f80f6   a844       MOVL         *-SP[4], XAR4
003f80f7   0746       ADDL         ACC, *-SP[6]
003f80f8   1e46       MOVL         *-SP[6], ACC
003f80f9   8f01       MOVL         XAR4, #0x010000
003f80fa   0000
003f80fb   a8a9       MOVL         ACC, XAR4
003f80fc   0f46       CMPL         ACC, *-SP[6]
003f80fd   66f5       SB           -11, HI
003f80fe   9249       MOV          AL, *-SP[9]
003f80ff   56c0       BF           161, NEQ
003f8100   00a1
003f8101   ffef       B            200, UNC
003f8102   00c8
003f8103   924a       MOV          AL, *-SP[10]
003f8104   284c       MOV          *-SP[12], #0xabcd
003f8105   abcd
003f8106   56c0       BF           197, NEQ
003f8107   00c5
003f8108   767f       LCR          0x3f836b
003f8109   836b
003f810a   8f3e       MOVL         XAR4, #0x3e8000
003f810b   8000
003f810c   9649       MOV          *-SP[9], AL
003f810d   2b4a       MOV          *-SP[10], #0
003f810e   a844       MOVL         *-SP[4], XAR4
003f810f   0200       MOVB         ACC, #0
003f8110   8f01       MOVL         XAR4, #0x010000
003f8111   0000
003f8112   1e46       MOVL         *-SP[6], ACC
003f8113   a8a9       MOVL         ACC, XAR4
003f8114   0f46       CMPL         ACC, *-SP[6]
003f8115   690d       SB           13, LOS
003f8116   1b42       CMP          *-SP[2], #-1
003f8117   ffff
003f8118   ec04       SBF          4, EQ
003f8119   2b4a       MOV          *-SP[10], #0
003f811a   284c       MOV          *-SP[12], #0xee09
003f811b   ee09
003f811c   0201       MOVB         ACC, #1
003f811d   0746       ADDL         ACC, *-SP[6]
003f811e   1e46       MOVL         *-SP[6], ACC
003f811f   a8a9       MOVL         ACC, XAR4
003f8120   0f46       CMPL         ACC, *-SP[6]
003f8121   66f5       SB           -11, HI
003f8122   9249       MOV          AL, *-SP[9]
003f8123   56c1       BF           168, EQ
003f8124   00a8
003f8125   ffef       B            175, UNC
003f8126   00af
003f8127   284c       MOV          *-SP[12], #0xabcd
003f8128   abcd
003f8129   767f       LCR          0x3f82f5
003f812a   82f5
003f812b   0200       MOVB         ACC, #0
003f812c   8f3d       MOVL         XAR4, #0x3d7800
003f812d   7800
003f812e   1e46       MOVL         *-SP[6], ACC
003f812f   a844       MOVL         *-SP[4], XAR4
003f8130   ff20       MOV          ACC, #1024
003f8131   0400
003f8132   0f46       CMPL         ACC, *-SP[6]
003f8133   ffe9       B            -154, LOS
003f8134   ff66
003f8135   8a44       MOVL         XAR4, *-SP[4]
003f8136   9284       MOV          AL, *XAR4++
003f8137   9642       MOV          *-SP[2], AL
003f8138   a844       MOVL         *-SP[4], XAR4
003f8139   767f       LCR          0x3f8310
003f813a   8310
003f813b   0201       MOVB         ACC, #1
003f813c   0746       ADDL         ACC, *-SP[6]
003f813d   1e46       MOVL         *-SP[6], ACC
003f813e   ff20       MOV          ACC, #1024
003f813f   0400
003f8140   0f46       CMPL         ACC, *-SP[6]
003f8141   66f4       SB           -12, HI
003f8142   ffef       B            -169, UNC
003f8143   ff57
003f8144   767f       LCR          0x3f82f5
003f8145   82f5
003f8146   924b       MOV          AL, *-SP[11]
003f8147   5201       CMPB         AL, #0x1
003f8148   ed1f       SBF          31, NEQ
003f8149   767f       LCR          0x3f83e8
003f814a   83e8
003f814b   9649       MOV          *-SP[9], AL
003f814c   767f       LCR          0x3f82b0
003f814d   82b0
003f814e   8f3d       MOVL         XAR4, #0x3d7800
003f814f   7800
003f8150   0ea9       MOVU         ACC, AL
003f8151   1e48       MOVL         *-SP[8], ACC
003f8152   a844       MOVL         *-SP[4], XAR4
003f8153   0200       MOVB         ACC, #0
003f8154   1e46       MOVL         *-SP[6], ACC
003f8155   ff20       MOV          ACC, #1024
003f8156   0400
003f8157   0f46       CMPL         ACC, *-SP[6]
003f8158   690c       SB           12, LOS
003f8159   8a44       MOVL         XAR4, *-SP[4]
003f815a   9284       MOV          AL, *XAR4++
003f815b   7242       ADD          *-SP[2], AL
003f815c   0201       MOVB         ACC, #1
003f815d   0746       ADDL         ACC, *-SP[6]
003f815e   a844       MOVL         *-SP[4], XAR4
003f815f   1e46       MOVL         *-SP[6], ACC
003f8160   ff20       MOV          ACC, #1024
003f8161   0400
003f8162   0f46       CMPL         ACC, *-SP[6]
003f8163   66f6       SB           -10, HI
003f8164   9249       MOV          AL, *-SP[9]
003f8165   ed6f       SBF          111, NEQ
003f8166   6f63       SB           99, UNC
003f8167   0200       MOVB         ACC, #0
003f8168   1e46       MOVL         *-SP[6], ACC
003f8169   ff20       MOV          ACC, #1025
003f816a   0401
003f816b   0f46       CMPL         ACC, *-SP[6]
003f816c   690b       SB           11, LOS
003f816d   767f       LCR          0x3f8256
003f816e   8256
003f816f   9642       MOV          *-SP[2], AL
003f8170   0201       MOVB         ACC, #1
003f8171   0746       ADDL         ACC, *-SP[6]
003f8172   1e46       MOVL         *-SP[6], ACC
003f8173   ff20       MOV          ACC, #1025
003f8174   0401
003f8175   0f46       CMPL         ACC, *-SP[6]
003f8176   66f7       SB           -9, HI
003f8177   0220       MOVB         ACC, #32
003f8178   761f       MOVW         DP, #0x1bf
003f8179   01bf
003f817a   284c       MOV          *-SP[12], #0xabcd
003f817b   abcd
003f817c   1e02       MOVL         @0x2, ACC
003f817d   0202       MOVB         ACC, #2
003f817e   1e04       MOVL         @0x4, ACC
003f817f   ffef       B            -279, UNC
003f8180   fee9
003f8181   767f       LCR          0x3f82f5
003f8182   82f5
003f8183   767f       LCR          0x3f841d
003f8184   841d
003f8185   9649       MOV          *-SP[9], AL
003f8186   767f       LCR          0x3f82b0
003f8187   82b0
003f8188   8f3d       MOVL         XAR4, #0x3d7800
003f8189   7800
003f818a   0ea9       MOVU         ACC, AL
003f818b   1e48       MOVL         *-SP[8], ACC
003f818c   a844       MOVL         *-SP[4], XAR4
003f818d   0200       MOVB         ACC, #0
003f818e   1e46       MOVL         *-SP[6], ACC
003f818f   ff20       MOV          ACC, #1024
003f8190   0400
003f8191   0f46       CMPL         ACC, *-SP[6]
003f8192   690c       SB           12, LOS
003f8193   8a44       MOVL         XAR4, *-SP[4]
003f8194   9284       MOV          AL, *XAR4++
003f8195   7242       ADD          *-SP[2], AL
003f8196   0201       MOVB         ACC, #1
003f8197   0746       ADDL         ACC, *-SP[6]
003f8198   a844       MOVL         *-SP[4], XAR4
003f8199   1e46       MOVL         *-SP[6], ACC
003f819a   ff20       MOV          ACC, #1024
003f819b   0400
003f819c   0f46       CMPL         ACC, *-SP[6]
003f819d   66f6       SB           -10, HI
003f819e   9249       MOV          AL, *-SP[9]
003f819f   ec2a       SBF          42, EQ
003f81a0   0222       MOVB         ACC, #34
003f81a1   284c       MOV          *-SP[12], #0xee08
003f81a2   ee08
003f81a3   6f2d       SB           45, UNC
003f81a4   767f       LCR          0x3f8376
003f81a5   8376
003f81a6   9649       MOV          *-SP[9], AL
003f81a7   767f       LCR          0x3f82b0
003f81a8   82b0
003f81a9   8f3e       MOVL         XAR4, #0x3e8000
003f81aa   8000
003f81ab   0ea9       MOVU         ACC, AL
003f81ac   a844       MOVL         *-SP[4], XAR4
003f81ad   1e48       MOVL         *-SP[8], ACC
003f81ae   8f01       MOVL         XAR4, #0x010000
003f81af   0000
003f81b0   0200       MOVB         ACC, #0
003f81b1   1e46       MOVL         *-SP[6], ACC
003f81b2   a8a9       MOVL         ACC, XAR4
003f81b3   0f46       CMPL         ACC, *-SP[6]
003f81b4   690d       SB           13, LOS
003f81b5   8a44       MOVL         XAR4, *-SP[4]
003f81b6   9284       MOV          AL, *XAR4++
003f81b7   7242       ADD          *-SP[2], AL
003f81b8   0201       MOVB         ACC, #1
003f81b9   a844       MOVL         *-SP[4], XAR4
003f81ba   0746       ADDL         ACC, *-SP[6]
003f81bb   1e46       MOVL         *-SP[6], ACC
003f81bc   8f01       MOVL         XAR4, #0x010000
003f81bd   0000
003f81be   a8a9       MOVL         ACC, XAR4
003f81bf   0f46       CMPL         ACC, *-SP[6]
003f81c0   66f5       SB           -11, HI
003f81c1   9249       MOV          AL, *-SP[9]
003f81c2   ed12       SBF          18, NEQ
003f81c3   6f06       SB           6, UNC
003f81c4   767f       LCR          0x3f8452
003f81c5   8452
003f81c6   5200       CMPB         AL, #0x0
003f81c7   9649       MOV          *-SP[9], AL
003f81c8   ed0c       SBF          12, NEQ
003f81c9   284c       MOV          *-SP[12], #0xabcd
003f81ca   abcd
003f81cb   0220       MOVB         ACC, #32
003f81cc   761f       MOVW         DP, #0x1bf
003f81cd   01bf
003f81ce   1e02       MOVL         @0x2, ACC
003f81cf   0202       MOVB         ACC, #2
003f81d0   761f       MOVW         DP, #0x1bf
003f81d1   01bf
003f81d2   1e04       MOVL         @0x4, ACC
003f81d3   6f0a       SB           10, UNC
003f81d4   0222       MOVB         ACC, #34
003f81d5   761f       MOVW         DP, #0x1bf
003f81d6   01bf
003f81d7   1e04       MOVL         @0x4, ACC
003f81d8   9249       MOV          AL, *-SP[9]
003f81d9   90ff       ANDB         AL, #0xff
003f81da   1aa9       OR           AL, #0xee00
003f81db   ee00
003f81dc   964c       MOV          *-SP[12], AL
003f81dd   767f       LCR          0x3f82f5
003f81de   82f5
003f81df   ffef       B            -375, UNC
003f81e0   fe89
003f81e1   0222       MOVB         ACC, #34
003f81e2   1e02       MOVL         @0x2, ACC
003f81e3   767f       LCR          0x3f82f5
003f81e4   82f5
003f81e5   2b49       MOV          *-SP[9], #0
003f81e6   ffef       B            -382, UNC
003f81e7   fe82
003f81e8   0220       MOVB         ACC, #32
003f81e9   1e02       MOVL         @0x2, ACC
003f81ea   0202       MOVB         ACC, #2
003f81eb   6f04       SB           4, UNC
003f81ec   0202       MOVB         ACC, #2
003f81ed   1e02       MOVL         @0x2, ACC
003f81ee   0220       MOVB         ACC, #32
003f81ef   1e04       MOVL         @0x4, ACC
003f81f0   6ff3       SB           -13, UNC
003f81f1   0222       MOVB         ACC, #34
003f81f2   6ffd       SB           -3, UNC
003f81f3   767f       LCR          0x3f82f5
003f81f4   82f5
003f81f5   8f00       MOVL         XAR4, #0x006fc6
003f81f6   6fc6
003f81f7   0220       MOVB         ACC, #32
003f81f8   767f       LCR          0x3f8b31
003f81f9   8b31
003f81fa   6feb       SB           -21, UNC
003f81fb   0202       MOVB         ACC, #2
003f81fc   1e02       MOVL         @0x2, ACC
003f81fd   0220       MOVB         ACC, #32
003f81fe   1e04       MOVL         @0x4, ACC
003f81ff   767f       LCR          0x3f82f5
003f8200   82f5
003f8201   9241       MOV          AL, *-SP[1]
003f8202   9649       MOV          *-SP[9], AL
003f8203   ffef       B            -411, UNC
003f8204   fe65
003f8205   9241       MOV          AL, *-SP[1]
003f8206   1ba9       CMP          AL, #30802
003f8207   7852
003f8208   6220       SB           32, GT
003f8209   1ba9       CMP          AL, #30802
003f820a   7852
003f820b   56c1       BF           -361, EQ
003f820c   fe97
003f820d   1ba9       CMP          AL, #8738
003f820e   2222
003f820f   620e       SB           14, GT
003f8210   1ba9       CMP          AL, #8738
003f8211   2222
003f8212   ecda       SBF          -38, EQ
003f8213   1ba9       CMP          AL, #-30584
003f8214   8888
003f8215   56c1       BF           -420, EQ
003f8216   fe5c
003f8217   5200       CMPB         AL, #0x0
003f8218   ecc9       SBF          -55, EQ
003f8219   1ba9       CMP          AL, #4369
003f821a   1111
003f821b   eccd       SBF          -51, EQ
003f821c   6fdf       SB           -33, UNC
003f821d   1ba9       CMP          AL, #13107
003f821e   3333
003f821f   ecd2       SBF          -46, EQ
003f8220   1ba9       CMP          AL, #21845
003f8221   5555
003f8222   ecd1       SBF          -47, EQ
003f8223   1ba9       CMP          AL, #30801
003f8224   7851
003f8225   56c1       BF           -424, EQ
003f8226   fe58
003f8227   6fd4       SB           -44, UNC
003f8228   1ba9       CMP          AL, #30810
003f8229   785a
003f822a   6211       SB           17, GT
003f822b   1ba9       CMP          AL, #30810
003f822c   785a
003f822d   ec97       SBF          -105, EQ
003f822e   1ba9       CMP          AL, #30803
003f822f   7853
003f8230   56c1       BF           -338, EQ
003f8231   feae
003f8232   1ba9       CMP          AL, #30808
003f8233   7858
003f8234   56c1       BF           -305, EQ
003f8235   fecf
003f8236   1ba9       CMP          AL, #30809
003f8237   7859
003f8238   56c1       BF           -148, EQ
003f8239   ff6c
003f823a   6fc1       SB           -63, UNC
003f823b   1ba9       CMP          AL, #31057
003f823c   7951
003f823d   56c1       BF           -278, EQ
003f823e   feea
003f823f   1ba9       CMP          AL, #31058
003f8240   7952
003f8241   56c1       BF           -253, EQ
003f8242   ff03
003f8243   1ba9       CMP          AL, #31059
003f8244   7953
003f8245   56c1       BF           -196, EQ
003f8246   ff3c
003f8247   6fb4       SB           -76, UNC
3f8248:              _Gpio_init:
003f8248   7622       EALLOW       
003f8249   0200       MOVB         ACC, #0
003f824a   761f       MOVW         DP, #0x1be
003f824b   01be
003f824c   1e06       MOVL         @0x6, ACC
003f824d   1e08       MOVL         @0x8, ACC
003f824e   1e06       MOVL         @0x6, ACC
003f824f   0222       MOVB         ACC, #34
003f8250   1e0a       MOVL         @0xa, ACC
003f8251   0200       MOVB         ACC, #0
003f8252   1e1a       MOVL         @0x1a, ACC
003f8253   761a       EDIS         
003f8254   ff69       SPM          #0
003f8255   0006       LRETR        
3f8256:              _spx_read:
003f8256   fe02       ADDB         SP, #2
003f8257   2b41       MOV          *-SP[1], #0
003f8258   7622       EALLOW       
003f8259   761f       MOVW         DP, #0x1bf
003f825a   01bf
003f825b   4701       TBIT         @0x1, #0x7
003f825c   ef12       SBF          18, NTC
003f825d   9a00       MOVB         AL, #0x0
003f825e   9b40       MOVB         AH, #0x40
003f825f   2bab       MOV          PL, #0
003f8260   28aa       MOV          PH, #0x0080
003f8261   0080
003f8262   1e02       MOVL         @0x2, ACC
003f8263   761f       MOVW         DP, #0x1be
003f8264   01be
003f8265   1a0b       OR           @0xb, #0x0040
003f8266   0040
003f8267   761f       MOVW         DP, #0x1bf
003f8268   01bf
003f8269   0600       MOVL         ACC, @0x0
003f826a   5608       AND          ACC, #0x0080 << 16
003f826b   0080
003f826c   0fab       CMPL         ACC, P
003f826d   ecfa       SBF          -6, EQ
003f826e   761f       MOVW         DP, #0x1be
003f826f   01be
003f8270   2b42       MOV          *-SP[2], #0
003f8271   180b       AND          @0xb, #0xffbf
003f8272   ffbf
003f8273   9242       MOV          AL, *-SP[2]
003f8274   5208       CMPB         AL, #0x8
003f8275   631d       SB           29, GEQ
003f8276   761f       MOVW         DP, #0x1bf
003f8277   01bf
003f8278   4701       TBIT         @0x1, #0x7
003f8279   effd       SBF          -3, NTC
003f827a   5603       MOV          ACC, *-SP[1] << 1
003f827b   0141
003f827c   4601       TBIT         @0x1, #0x6
003f827d   9641       MOV          *-SP[1], AL
003f827e   ef02       SBF          2, NTC
003f827f   0a41       INC          *-SP[1]
003f8280   0600       MOVL         ACC, @0x0
003f8281   2bab       MOV          PL, #0
003f8282   28aa       MOV          PH, #0x0080
003f8283   0080
003f8284   5608       AND          ACC, #0x0080 << 16
003f8285   0080
003f8286   0fab       CMPL         ACC, P
003f8287   ecf9       SBF          -7, EQ
003f8288   5603       MOV          ACC, *-SP[1] << 1
003f8289   0141
003f828a   4601       TBIT         @0x1, #0x6
003f828b   9641       MOV          *-SP[1], AL
003f828c   ef02       SBF          2, NTC
003f828d   0a41       INC          *-SP[1]
003f828e   0a42       INC          *-SP[2]
003f828f   9242       MOV          AL, *-SP[2]
003f8290   5208       CMPB         AL, #0x8
003f8291   64e5       SB           -27, LT
003f8292   761f       MOVW         DP, #0x1bf
003f8293   01bf
003f8294   4701       TBIT         @0x1, #0x7
003f8295   effd       SBF          -3, NTC
003f8296   9a00       MOVB         AL, #0x0
003f8297   9b40       MOVB         AH, #0x40
003f8298   2bab       MOV          PL, #0
003f8299   28aa       MOV          PH, #0x0080
003f829a   0080
003f829b   1e02       MOVL         @0x2, ACC
003f829c   761f       MOVW         DP, #0x1be
003f829d   01be
003f829e   1a0b       OR           @0xb, #0x0040
003f829f   0040
003f82a0   761f       MOVW         DP, #0x1bf
003f82a1   01bf
003f82a2   0600       MOVL         ACC, @0x0
003f82a3   5608       AND          ACC, #0x0080 << 16
003f82a4   0080
003f82a5   0fab       CMPL         ACC, P
003f82a6   ecfa       SBF          -6, EQ
003f82a7   761f       MOVW         DP, #0x1be
003f82a8   01be
003f82a9   180b       AND          @0xb, #0xffbf
003f82aa   ffbf
003f82ab   761a       EDIS         
003f82ac   9241       MOV          AL, *-SP[1]
003f82ad   ff69       SPM          #0
003f82ae   fe82       SUBB         SP, #2
003f82af   0006       LRETR        
3f82b0:              _spx_read_wait:
003f82b0   fe02       ADDB         SP, #2
003f82b1   2b41       MOV          *-SP[1], #0
003f82b2   7622       EALLOW       
003f82b3   761f       MOVW         DP, #0x1bf
003f82b4   01bf
003f82b5   4701       TBIT         @0x1, #0x7
003f82b6   ef12       SBF          18, NTC
003f82b7   9a00       MOVB         AL, #0x0
003f82b8   9b40       MOVB         AH, #0x40
003f82b9   2bab       MOV          PL, #0
003f82ba   28aa       MOV          PH, #0x0080
003f82bb   0080
003f82bc   1e02       MOVL         @0x2, ACC
003f82bd   761f       MOVW         DP, #0x1be
003f82be   01be
003f82bf   1a0b       OR           @0xb, #0x0040
003f82c0   0040
003f82c1   761f       MOVW         DP, #0x1bf
003f82c2   01bf
003f82c3   0600       MOVL         ACC, @0x0
003f82c4   5608       AND          ACC, #0x0080 << 16
003f82c5   0080
003f82c6   0fab       CMPL         ACC, P
003f82c7   ecfa       SBF          -6, EQ
003f82c8   761f       MOVW         DP, #0x1be
003f82c9   01be
003f82ca   2b42       MOV          *-SP[2], #0
003f82cb   180b       AND          @0xb, #0xff3f
003f82cc   ff3f
003f82cd   9242       MOV          AL, *-SP[2]
003f82ce   5208       CMPB         AL, #0x8
003f82cf   631d       SB           29, GEQ
003f82d0   761f       MOVW         DP, #0x1bf
003f82d1   01bf
003f82d2   4701       TBIT         @0x1, #0x7
003f82d3   effd       SBF          -3, NTC
003f82d4   5603       MOV          ACC, *-SP[1] << 1
003f82d5   0141
003f82d6   4601       TBIT         @0x1, #0x6
003f82d7   9641       MOV          *-SP[1], AL
003f82d8   ef02       SBF          2, NTC
003f82d9   0a41       INC          *-SP[1]
003f82da   0600       MOVL         ACC, @0x0
003f82db   2bab       MOV          PL, #0
003f82dc   28aa       MOV          PH, #0x0080
003f82dd   0080
003f82de   5608       AND          ACC, #0x0080 << 16
003f82df   0080
003f82e0   0fab       CMPL         ACC, P
003f82e1   ecf9       SBF          -7, EQ
003f82e2   5603       MOV          ACC, *-SP[1] << 1
003f82e3   0141
003f82e4   4601       TBIT         @0x1, #0x6
003f82e5   9641       MOV          *-SP[1], AL
003f82e6   ef02       SBF          2, NTC
003f82e7   0a41       INC          *-SP[1]
003f82e8   0a42       INC          *-SP[2]
003f82e9   9242       MOV          AL, *-SP[2]
003f82ea   5208       CMPB         AL, #0x8
003f82eb   64e5       SB           -27, LT
003f82ec   761f       MOVW         DP, #0x1bf
003f82ed   01bf
003f82ee   4701       TBIT         @0x1, #0x7
003f82ef   effd       SBF          -3, NTC
003f82f0   761a       EDIS         
003f82f1   9241       MOV          AL, *-SP[1]
003f82f2   ff69       SPM          #0
003f82f3   fe82       SUBB         SP, #2
003f82f4   0006       LRETR        
3f82f5:              _spx_read_nowait:
003f82f5   7622       EALLOW       
003f82f6   9a00       MOVB         AL, #0x0
003f82f7   9b40       MOVB         AH, #0x40
003f82f8   761f       MOVW         DP, #0x1bf
003f82f9   01bf
003f82fa   2bab       MOV          PL, #0
003f82fb   28aa       MOV          PH, #0x0080
003f82fc   0080
003f82fd   1e02       MOVL         @0x2, ACC
003f82fe   761f       MOVW         DP, #0x1be
003f82ff   01be
003f8300   1a0b       OR           @0xb, #0x0040
003f8301   0040
003f8302   761f       MOVW         DP, #0x1bf
003f8303   01bf
003f8304   0600       MOVL         ACC, @0x0
003f8305   5608       AND          ACC, #0x0080 << 16
003f8306   0080
003f8307   0fab       CMPL         ACC, P
003f8308   ecfa       SBF          -6, EQ
003f8309   761f       MOVW         DP, #0x1be
003f830a   01be
003f830b   180b       AND          @0xb, #0xffbf
003f830c   ffbf
003f830d   761a       EDIS         
003f830e   ff69       SPM          #0
003f830f   0006       LRETR        
3f8310:              _spx_write:
003f8310   fe02       ADDB         SP, #2
003f8311   9641       MOV          *-SP[1], AL
003f8312   7622       EALLOW       
003f8313   761f       MOVW         DP, #0x1be
003f8314   01be
003f8315   2b42       MOV          *-SP[2], #0
003f8316   1a0b       OR           @0xb, #0x0040
003f8317   0040
003f8318   9242       MOV          AL, *-SP[2]
003f8319   5208       CMPB         AL, #0x8
003f831a   632f       SB           47, GEQ
003f831b   761f       MOVW         DP, #0x1bf
003f831c   01bf
003f831d   4701       TBIT         @0x1, #0x7
003f831e   effd       SBF          -3, NTC
003f831f   cc41       AND          AL, *-SP[1], #0x8000
003f8320   8000
003f8321   1ba9       CMP          AL, #-32768
003f8322   8000
003f8323   ed05       SBF          5, NEQ
003f8324   9a00       MOVB         AL, #0x0
003f8325   9b40       MOVB         AH, #0x40
003f8326   1e02       MOVL         @0x2, ACC
003f8327   6f04       SB           4, UNC
003f8328   9a00       MOVB         AL, #0x0
003f8329   9b40       MOVB         AH, #0x40
003f832a   1e04       MOVL         @0x4, ACC
003f832b   5603       MOV          ACC, *-SP[1] << 1
003f832c   0141
003f832d   2bab       MOV          PL, #0
003f832e   28aa       MOV          PH, #0x0080
003f832f   0080
003f8330   9641       MOV          *-SP[1], AL
003f8331   0600       MOVL         ACC, @0x0
003f8332   5608       AND          ACC, #0x0080 << 16
003f8333   0080
003f8334   0fab       CMPL         ACC, P
003f8335   ecfc       SBF          -4, EQ
003f8336   cc41       AND          AL, *-SP[1], #0x8000
003f8337   8000
003f8338   1ba9       CMP          AL, #-32768
003f8339   8000
003f833a   ed05       SBF          5, NEQ
003f833b   9a00       MOVB         AL, #0x0
003f833c   9b40       MOVB         AH, #0x40
003f833d   1e02       MOVL         @0x2, ACC
003f833e   6f04       SB           4, UNC
003f833f   9a00       MOVB         AL, #0x0
003f8340   9b40       MOVB         AH, #0x40
003f8341   1e04       MOVL         @0x4, ACC
003f8342   5603       MOV          ACC, *-SP[1] << 1
003f8343   0141
003f8344   0a42       INC          *-SP[2]
003f8345   9641       MOV          *-SP[1], AL
003f8346   9242       MOV          AL, *-SP[2]
003f8347   5208       CMPB         AL, #0x8
003f8348   64d3       SB           -45, LT
003f8349   ff69       SPM          #0
003f834a   fe82       SUBB         SP, #2
003f834b   0006       LRETR        
3f834c:              _spx_write_end:
003f834c   7622       EALLOW       
003f834d   761f       MOVW         DP, #0x1bf
003f834e   01bf
003f834f   4701       TBIT         @0x1, #0x7
003f8350   effd       SBF          -3, NTC
003f8351   0600       MOVL         ACC, @0x0
003f8352   2bab       MOV          PL, #0
003f8353   28aa       MOV          PH, #0x0080
003f8354   0080
003f8355   5608       AND          ACC, #0x0080 << 16
003f8356   0080
003f8357   0fab       CMPL         ACC, P
003f8358   ecf9       SBF          -7, EQ
003f8359   ff69       SPM          #0
003f835a   761f       MOVW         DP, #0x1be
003f835b   01be
003f835c   180b       AND          @0xb, #0xffbf
003f835d   ffbf
003f835e   0006       LRETR        
3f835f:              _Flash_version_check:
003f835f   fe02       ADDB         SP, #2
003f8360   767f       LCR          0x3f8b8f
003f8361   8b8f
003f8362   1ba9       CMP          AL, #770
003f8363   0302
003f8364   9641       MOV          *-SP[1], AL
003f8365   ec03       SBF          3, EQ
003f8366   9a01       MOVB         AL, #0x1
003f8367   6f02       SB           2, UNC
003f8368   9a00       MOVB         AL, #0x0
003f8369   fe82       SUBB         SP, #2
003f836a   0006       LRETR        
3f836b:              _Flash_erase_all:
003f836b   fe02       ADDB         SP, #2
003f836c   7622       EALLOW       
003f836d   9a0f       MOVB         AL, #0xf
003f836e   8f3f       MOVL         XAR4, #0x3f9000
003f836f   9000
003f8370   ff69       SPM          #0
003f8371   767f       LCR          0x3f8614
003f8372   8614
003f8373   9641       MOV          *-SP[1], AL
003f8374   fe82       SUBB         SP, #2
003f8375   0006       LRETR        
3f8376:              _Flash_depletion_recover:
003f8376   fe02       ADDB         SP, #2
003f8377   7622       EALLOW       
003f8378   ff69       SPM          #0
003f8379   767f       LCR          0x3f8ab1
003f837a   8ab1
003f837b   9641       MOV          *-SP[1], AL
003f837c   fe82       SUBB         SP, #2
003f837d   0006       LRETR        
3f837e:              _Flash_prog_spx:
003f837e   fe08       ADDB         SP, #8
003f837f   2b44       MOV          *-SP[4], #0
003f8380   2b43       MOV          *-SP[3], #0
003f8381   1b44       CMP          *-SP[4], #256
003f8382   0100
003f8383   672d       SB           45, HIS
003f8384   2b45       MOV          *-SP[5], #0
003f8385   9245       MOV          AL, *-SP[5]
003f8386   52ff       CMPB         AL, #0xff
003f8387   670b       SB           11, HIS
003f8388   767f       LCR          0x3f8256
003f8389   8256
003f838a   5845       MOVZ         AR0, *-SP[5]
003f838b   8f3f       MOVL         XAR4, #0x3f9040
003f838c   9040
003f838d   9694       MOV          *+XAR4[AR0], AL
003f838e   0a45       INC          *-SP[5]
003f838f   9245       MOV          AL, *-SP[5]
003f8390   52ff       CMPB         AL, #0xff
003f8391   68f7       SB           -9, LO
003f8392   767f       LCR          0x3f82b0
003f8393   82b0
003f8394   8f3e       MOVL         XAR4, #0x3e8000
003f8395   8000
003f8396   8f7f       MOVL         XAR5, #0x3f9040
003f8397   9040
003f8398   761f       MOVW         DP, #0xfe44
003f8399   fe44
003f839a   963f       MOV          @0x3f, AL
003f839b   5603       MOV          ACC, *-SP[4] << 8
003f839c   0844
003f839d   88a9       MOVZ         AR6, AL
003f839e   a8a9       MOVL         ACC, XAR4
003f839f   8f3f       MOVL         XAR4, #0x3f9000
003f83a0   9000
003f83a1   0da6       ADDU         ACC, AR6
003f83a2   1e48       MOVL         *-SP[8], ACC
003f83a3   ff20       MOV          ACC, #256
003f83a4   0100
003f83a5   a842       MOVL         *-SP[2], XAR4
003f83a6   8a48       MOVL         XAR4, *-SP[8]
003f83a7   767f       LCR          0x3f856b
003f83a8   856b
003f83a9   9843       OR           *-SP[3], AL
003f83aa   767f       LCR          0x3f82f5
003f83ab   82f5
003f83ac   0a44       INC          *-SP[4]
003f83ad   1b44       CMP          *-SP[4], #256
003f83ae   0100
003f83af   68d5       SB           -43, LO
003f83b0   9243       MOV          AL, *-SP[3]
003f83b1   fe88       SUBB         SP, #8
003f83b2   0006       LRETR        
3f83b3:              _Flash_verify_spx:
003f83b3   fe08       ADDB         SP, #8
003f83b4   2b44       MOV          *-SP[4], #0
003f83b5   2b43       MOV          *-SP[3], #0
003f83b6   1b44       CMP          *-SP[4], #256
003f83b7   0100
003f83b8   672d       SB           45, HIS
003f83b9   2b45       MOV          *-SP[5], #0
003f83ba   9245       MOV          AL, *-SP[5]
003f83bb   52ff       CMPB         AL, #0xff
003f83bc   670b       SB           11, HIS
003f83bd   767f       LCR          0x3f8256
003f83be   8256
003f83bf   5845       MOVZ         AR0, *-SP[5]
003f83c0   8f3f       MOVL         XAR4, #0x3f9040
003f83c1   9040
003f83c2   9694       MOV          *+XAR4[AR0], AL
003f83c3   0a45       INC          *-SP[5]
003f83c4   9245       MOV          AL, *-SP[5]
003f83c5   52ff       CMPB         AL, #0xff
003f83c6   68f7       SB           -9, LO
003f83c7   767f       LCR          0x3f82b0
003f83c8   82b0
003f83c9   8f3e       MOVL         XAR4, #0x3e8000
003f83ca   8000
003f83cb   8f7f       MOVL         XAR5, #0x3f9040
003f83cc   9040
003f83cd   761f       MOVW         DP, #0xfe44
003f83ce   fe44
003f83cf   963f       MOV          @0x3f, AL
003f83d0   5603       MOV          ACC, *-SP[4] << 8
003f83d1   0844
003f83d2   88a9       MOVZ         AR6, AL
003f83d3   a8a9       MOVL         ACC, XAR4
003f83d4   8f3f       MOVL         XAR4, #0x3f9000
003f83d5   9000
003f83d6   0da6       ADDU         ACC, AR6
003f83d7   1e48       MOVL         *-SP[8], ACC
003f83d8   ff20       MOV          ACC, #256
003f83d9   0100
003f83da   a842       MOVL         *-SP[2], XAR4
003f83db   8a48       MOVL         XAR4, *-SP[8]
003f83dc   767f       LCR          0x3f8a7e
003f83dd   8a7e
003f83de   9843       OR           *-SP[3], AL
003f83df   767f       LCR          0x3f82f5
003f83e0   82f5
003f83e1   0a44       INC          *-SP[4]
003f83e2   1b44       CMP          *-SP[4], #256
003f83e3   0100
003f83e4   68d5       SB           -43, LO
003f83e5   9243       MOV          AL, *-SP[3]
003f83e6   fe88       SUBB         SP, #8
003f83e7   0006       LRETR        
3f83e8:              _OTP_prog_spx:
003f83e8   fe08       ADDB         SP, #8
003f83e9   2b44       MOV          *-SP[4], #0
003f83ea   2b43       MOV          *-SP[3], #0
003f83eb   9244       MOV          AL, *-SP[4]
003f83ec   5204       CMPB         AL, #0x4
003f83ed   672d       SB           45, HIS
003f83ee   2b45       MOV          *-SP[5], #0
003f83ef   9245       MOV          AL, *-SP[5]
003f83f0   52ff       CMPB         AL, #0xff
003f83f1   670b       SB           11, HIS
003f83f2   767f       LCR          0x3f8256
003f83f3   8256
003f83f4   5845       MOVZ         AR0, *-SP[5]
003f83f5   8f3f       MOVL         XAR4, #0x3f9040
003f83f6   9040
003f83f7   9694       MOV          *+XAR4[AR0], AL
003f83f8   0a45       INC          *-SP[5]
003f83f9   9245       MOV          AL, *-SP[5]
003f83fa   52ff       CMPB         AL, #0xff
003f83fb   68f7       SB           -9, LO
003f83fc   767f       LCR          0x3f82b0
003f83fd   82b0
003f83fe   8f3d       MOVL         XAR4, #0x3d7800
003f83ff   7800
003f8400   8f7f       MOVL         XAR5, #0x3f9040
003f8401   9040
003f8402   761f       MOVW         DP, #0xfe44
003f8403   fe44
003f8404   963f       MOV          @0x3f, AL
003f8405   5603       MOV          ACC, *-SP[4] << 8
003f8406   0844
003f8407   88a9       MOVZ         AR6, AL
003f8408   a8a9       MOVL         ACC, XAR4
003f8409   8f3f       MOVL         XAR4, #0x3f9000
003f840a   9000
003f840b   0da6       ADDU         ACC, AR6
003f840c   1e48       MOVL         *-SP[8], ACC
003f840d   ff20       MOV          ACC, #256
003f840e   0100
003f840f   a842       MOVL         *-SP[2], XAR4
003f8410   8a48       MOVL         XAR4, *-SP[8]
003f8411   767f       LCR          0x3f856b
003f8412   856b
003f8413   9843       OR           *-SP[3], AL
003f8414   767f       LCR          0x3f82f5
003f8415   82f5
003f8416   0a44       INC          *-SP[4]
003f8417   9244       MOV          AL, *-SP[4]
003f8418   5204       CMPB         AL, #0x4
003f8419   68d5       SB           -43, LO
003f841a   9243       MOV          AL, *-SP[3]
003f841b   fe88       SUBB         SP, #8
003f841c   0006       LRETR        
3f841d:              _OTP_verify_spx:
003f841d   fe08       ADDB         SP, #8
003f841e   2b44       MOV          *-SP[4], #0
003f841f   2b43       MOV          *-SP[3], #0
003f8420   9244       MOV          AL, *-SP[4]
003f8421   5204       CMPB         AL, #0x4
003f8422   672d       SB           45, HIS
003f8423   2b45       MOV          *-SP[5], #0
003f8424   9245       MOV          AL, *-SP[5]
003f8425   52ff       CMPB         AL, #0xff
003f8426   670b       SB           11, HIS
003f8427   767f       LCR          0x3f8256
003f8428   8256
003f8429   5845       MOVZ         AR0, *-SP[5]
003f842a   8f3f       MOVL         XAR4, #0x3f9040
003f842b   9040
003f842c   9694       MOV          *+XAR4[AR0], AL
003f842d   0a45       INC          *-SP[5]
003f842e   9245       MOV          AL, *-SP[5]
003f842f   52ff       CMPB         AL, #0xff
003f8430   68f7       SB           -9, LO
003f8431   767f       LCR          0x3f82b0
003f8432   82b0
003f8433   8f3d       MOVL         XAR4, #0x3d7800
003f8434   7800
003f8435   8f7f       MOVL         XAR5, #0x3f9040
003f8436   9040
003f8437   761f       MOVW         DP, #0xfe44
003f8438   fe44
003f8439   963f       MOV          @0x3f, AL
003f843a   5603       MOV          ACC, *-SP[4] << 8
003f843b   0844
003f843c   88a9       MOVZ         AR6, AL
003f843d   a8a9       MOVL         ACC, XAR4
003f843e   8f3f       MOVL         XAR4, #0x3f9000
003f843f   9000
003f8440   0da6       ADDU         ACC, AR6
003f8441   1e48       MOVL         *-SP[8], ACC
003f8442   ff20       MOV          ACC, #256
003f8443   0100
003f8444   a842       MOVL         *-SP[2], XAR4
003f8445   8a48       MOVL         XAR4, *-SP[8]
003f8446   767f       LCR          0x3f8a7e
003f8447   8a7e
003f8448   9843       OR           *-SP[3], AL
003f8449   767f       LCR          0x3f82f5
003f844a   82f5
003f844b   0a44       INC          *-SP[4]
003f844c   9244       MOV          AL, *-SP[4]
003f844d   5204       CMPB         AL, #0x4
003f844e   68d5       SB           -43, LO
003f844f   9243       MOV          AL, *-SP[3]
003f8450   fe88       SUBB         SP, #8
003f8451   0006       LRETR        
3f8452:              _FLASH_blankcheck:
003f8452   fe08       ADDB         SP, #8
003f8453   8f3e       MOVL         XAR4, #0x3e8000
003f8454   8000
003f8455   0200       MOVB         ACC, #0
003f8456   a844       MOVL         *-SP[4], XAR4
003f8457   2b41       MOV          *-SP[1], #0
003f8458   1e46       MOVL         *-SP[6], ACC
003f8459   8f01       MOVL         XAR4, #0x010000
003f845a   0000
003f845b   a8a9       MOVL         ACC, XAR4
003f845c   0f46       CMPL         ACC, *-SP[6]
003f845d   6911       SB           17, LOS
003f845e   8a44       MOVL         XAR4, *-SP[4]
003f845f   9284       MOV          AL, *XAR4++
003f8460   9647       MOV          *-SP[7], AL
003f8461   1ba9       CMP          AL, #-1
003f8462   ffff
003f8463   56b0       MOVB         *-SP[1], #0x01, NEQ
003f8464   0141
003f8465   0201       MOVB         ACC, #1
003f8466   a844       MOVL         *-SP[4], XAR4
003f8467   0746       ADDL         ACC, *-SP[6]
003f8468   8f01       MOVL         XAR4, #0x010000
003f8469   0000
003f846a   1e46       MOVL         *-SP[6], ACC
003f846b   a8a9       MOVL         ACC, XAR4
003f846c   0f46       CMPL         ACC, *-SP[6]
003f846d   66f1       SB           -15, HI
003f846e   9241       MOV          AL, *-SP[1]
003f846f   fe88       SUBB         SP, #8
003f8470   0006       LRETR        
3f8471:              _toggle_led:
003f8471   0220       MOVB         ACC, #32
003f8472   761f       MOVW         DP, #0x1bf
003f8473   01bf
003f8474   1e02       MOVL         @0x2, ACC
003f8475   0202       MOVB         ACC, #2
003f8476   1e04       MOVL         @0x4, ACC
003f8477   767f       LCR          0x3f8482
003f8478   8482
003f8479   761f       MOVW         DP, #0x1bf
003f847a   01bf
003f847b   0202       MOVB         ACC, #2
003f847c   1e02       MOVL         @0x2, ACC
003f847d   0220       MOVB         ACC, #32
003f847e   1e04       MOVL         @0x4, ACC
003f847f   767f       LCR          0x3f8482
003f8480   8482
003f8481   6ff0       SB           -16, UNC
3f8482:              _delay_loop:
003f8482   fe02       ADDB         SP, #2
003f8483   0200       MOVB         ACC, #0
003f8484   8f1e       MOVL         XAR4, #0x1e8480
003f8485   8480
003f8486   1e42       MOVL         *-SP[2], ACC
003f8487   a8a9       MOVL         ACC, XAR4
003f8488   0f42       CMPL         ACC, *-SP[2]
003f8489   6507       SB           7, LEQ
003f848a   0201       MOVB         ACC, #1
003f848b   0742       ADDL         ACC, *-SP[2]
003f848c   1e42       MOVL         *-SP[2], ACC
003f848d   a8a9       MOVL         ACC, XAR4
003f848e   0f42       CMPL         ACC, *-SP[2]
003f848f   62fb       SB           -5, GT
003f8490   ff69       SPM          #0
003f8491   fe82       SUBB         SP, #2
003f8492   0006       LRETR        
3f8493:              _set_pll:
003f8493   761f       MOVW         DP, #0x1c0
003f8494   01c0
003f8495   cc11       AND          AL, @0x11, #0x8
003f8496   0008
003f8497   ffc2       LSR          AL, 3
003f8498   5201       CMPB         AL, #0x1
003f8499   ec1b       SBF          27, EQ
003f849a   9221       MOV          AL, @0x21
003f849b   900f       ANDB         AL, #0xf
003f849c   520a       CMPB         AL, #0xa
003f849d   ec15       SBF          21, EQ
003f849e   7622       EALLOW       
003f849f   1a11       OR           @0x11, #0x0040
003f84a0   0040
003f84a1   cc21       AND          AL, @0x21, #0xfff0
003f84a2   fff0
003f84a3   500a       ORB          AL, #0xa
003f84a4   9621       MOV          @0x21, AL
003f84a5   761a       EDIS         
003f84a6   7622       EALLOW       
003f84a7   56bf       MOVB         @0x29, #0x68, UNC
003f84a8   6829
003f84a9   761a       EDIS         
003f84aa   9211       MOV          AL, @0x11
003f84ab   9001       ANDB         AL, #0x1
003f84ac   5201       CMPB         AL, #0x1
003f84ad   edfd       SBF          -3, NEQ
003f84ae   7622       EALLOW       
003f84af   1811       AND          @0x11, #0xffbf
003f84b0   ffbf
003f84b1   761a       EDIS         
003f84b2   9a00       MOVB         AL, #0x0
003f84b3   0006       LRETR        
003f84b4   9a01       MOVB         AL, #0x1
003f84b5   0006       LRETR        
3f84b6:              _InitSysCtrl1:
003f84b6   9a05       MOVB         AL, #0x5
003f84b7   9b00       MOVB         AH, #0x0
003f84b8   767f       LCR          0x3f84e8
003f84b9   84e8
003f84ba   0006       LRETR        
3f84bb:              _InitFlash:
003f84bb   7622       EALLOW       
003f84bc   761f       MOVW         DP, #0x2a
003f84bd   002a
003f84be   1a00       OR           @0x0, #0x0001
003f84bf   0001
003f84c0   cc06       AND          AL, @0x6, #0xf0ff
003f84c1   f0ff
003f84c2   1aa9       OR           AL, #0x0300
003f84c3   0300
003f84c4   9606       MOV          @0x6, AL
003f84c5   cc06       AND          AL, @0x6, #0xfff0
003f84c6   fff0
003f84c7   5003       ORB          AL, #0x3
003f84c8   9606       MOV          @0x6, AL
003f84c9   cc07       AND          AL, @0x7, #0xffe0
003f84ca   ffe0
003f84cb   5005       ORB          AL, #0x5
003f84cc   9607       MOV          @0x7, AL
003f84cd   1a04       OR           @0x4, #0x01ff
003f84ce   01ff
003f84cf   1a05       OR           @0x5, #0x01ff
003f84d0   01ff
003f84d1   761a       EDIS         
003f84d2   f607       RPT          #7
003f84d3   7700    || NOP          
003f84d4   ff69       SPM          #0
003f84d5   0006       LRETR        
3f84d6:              _ServiceDog:
003f84d6   7622       EALLOW       
003f84d7   761f       MOVW         DP, #0x1c0
003f84d8   01c0
003f84d9   56bf       MOVB         @0x25, #0x55, UNC
003f84da   5525
003f84db   56bf       MOVB         @0x25, #0xaa, UNC
003f84dc   aa25
003f84dd   761a       EDIS         
003f84de   ff69       SPM          #0
003f84df   0006       LRETR        
3f84e0:              _DisableDog:
003f84e0   7622       EALLOW       
003f84e1   761f       MOVW         DP, #0x1c0
003f84e2   01c0
003f84e3   56bf       MOVB         @0x29, #0x68, UNC
003f84e4   6829
003f84e5   761a       EDIS         
003f84e6   ff69       SPM          #0
003f84e7   0006       LRETR        
3f84e8:              _InitPll:
003f84e8   761f       MOVW         DP, #0x1c0
003f84e9   01c0
003f84ea   fe02       ADDB         SP, #2
003f84eb   4311       TBIT         @0x11, #0x3
003f84ec   9742       MOV          *-SP[2], AH
003f84ed   9641       MOV          *-SP[1], AL
003f84ee   ef02       SBF          2, NTC
003f84ef   7625       ESTOP0       
003f84f0   4111       TBIT         @0x11, #0x1
003f84f1   ef05       SBF          5, NTC
003f84f2   7622       EALLOW       
003f84f3   1811       AND          @0x11, #0xfffd
003f84f4   fffd
003f84f5   761a       EDIS         
003f84f6   9221       MOV          AL, @0x21
003f84f7   900f       ANDB         AL, #0xf
003f84f8   5441       CMP          AL, *-SP[1]
003f84f9   ec1d       SBF          29, EQ
003f84fa   7622       EALLOW       
003f84fb   1a11       OR           @0x11, #0x0040
003f84fc   0040
003f84fd   9241       MOV          AL, *-SP[1]
003f84fe   cd21       AND          AH, @0x21, #0xfff0
003f84ff   fff0
003f8500   900f       ANDB         AL, #0xf
003f8501   caa8       OR           AL, @AH
003f8502   9621       MOV          @0x21, AL
003f8503   761a       EDIS         
003f8504   ff69       SPM          #0
003f8505   767f       LCR          0x3f84e0
003f8506   84e0
003f8507   9211       MOV          AL, @0x11
003f8508   9001       ANDB         AL, #0x1
003f8509   5201       CMPB         AL, #0x1
003f850a   edfd       SBF          -3, NEQ
003f850b   7622       EALLOW       
003f850c   1811       AND          @0x11, #0xffbf
003f850d   ffbf
003f850e   9242       MOV          AL, *-SP[2]
003f850f   cd11       AND          AH, @0x11, #0xfffd
003f8510   fffd
003f8511   9001       ANDB         AL, #0x1
003f8512   ff80       LSL          AL, 1
003f8513   caa8       OR           AL, @AH
003f8514   9611       MOV          @0x11, AL
003f8515   761a       EDIS         
003f8516   fe82       SUBB         SP, #2
003f8517   0006       LRETR        
3f8518:              _InitPeripheralClocks:
003f8518   7622       EALLOW       
003f8519   761f       MOVW         DP, #0x1c0
003f851a   01c0
003f851b   56bf       MOVB         @0x1a, #0x01, UNC
003f851c   011a
003f851d   56bf       MOVB         @0x1b, #0x02, UNC
003f851e   021b
003f851f   cc10       AND          AL, @0x10, #0xfffc
003f8520   fffc
003f8521   5002       ORB          AL, #0x2
003f8522   9610       MOV          @0x10, AL
003f8523   1a1c       OR           @0x1c, #0x0008
003f8524   0008
003f8525   1a1c       OR           @0x1c, #0x0010
003f8526   0010
003f8527   1a1d       OR           @0x1d, #0x0100
003f8528   0100
003f8529   1a1d       OR           @0x1d, #0x0200
003f852a   0200
003f852b   1a1d       OR           @0x1d, #0x0001
003f852c   0001
003f852d   1a1d       OR           @0x1d, #0x0002
003f852e   0002
003f852f   1a1d       OR           @0x1d, #0x0004
003f8530   0004
003f8531   1a1c       OR           @0x1c, #0x0400
003f8532   0400
003f8533   1a1c       OR           @0x1c, #0x0100
003f8534   0100
003f8535   1a1c       OR           @0x1c, #0x0004
003f8536   0004
003f8537   761a       EDIS         
003f8538   ff69       SPM          #0
003f8539   0006       LRETR        
3f853a:              _CsmUnlock:
003f853a   fe02       ADDB         SP, #2
003f853b   7622       EALLOW       
003f853c   761f       MOVW         DP, #0x2b
003f853d   002b
003f853e   2820       MOV          @0x20, #0xffff
003f853f   ffff
003f8540   2821       MOV          @0x21, #0xffff
003f8541   ffff
003f8542   2822       MOV          @0x22, #0xffff
003f8543   ffff
003f8544   2823       MOV          @0x23, #0xffff
003f8545   ffff
003f8546   2824       MOV          @0x24, #0xffff
003f8547   ffff
003f8548   2825       MOV          @0x25, #0xffff
003f8549   ffff
003f854a   2826       MOV          @0x26, #0xffff
003f854b   ffff
003f854c   2827       MOV          @0x27, #0xffff
003f854d   ffff
003f854e   761a       EDIS         
003f854f   761f       MOVW         DP, #0xfdff
003f8550   fdff
003f8551   9238       MOV          AL, @0x38
003f8552   9641       MOV          *-SP[1], AL
003f8553   9239       MOV          AL, @0x39
003f8554   9641       MOV          *-SP[1], AL
003f8555   923a       MOV          AL, @0x3a
003f8556   9641       MOV          *-SP[1], AL
003f8557   923b       MOV          AL, @0x3b
003f8558   9641       MOV          *-SP[1], AL
003f8559   923c       MOV          AL, @0x3c
003f855a   9641       MOV          *-SP[1], AL
003f855b   923d       MOV          AL, @0x3d
003f855c   9641       MOV          *-SP[1], AL
003f855d   923e       MOV          AL, @0x3e
003f855e   9641       MOV          *-SP[1], AL
003f855f   923f       MOV          AL, @0x3f
003f8560   761f       MOVW         DP, #0x2b
003f8561   002b
003f8562   9641       MOV          *-SP[1], AL
003f8563   402f       TBIT         @0x2f, #0x0
003f8564   ee03       SBF          3, TC
003f8565   9a01       MOVB         AL, #0x1
003f8566   6f02       SB           2, UNC
003f8567   9a00       MOVB         AL, #0x0
003f8568   ff69       SPM          #0
003f8569   fe82       SUBB         SP, #2
003f856a   0006       LRETR        
3f856b:              _Flash2808_Program:
003f856b   fe12       ADDB         SP, #18
003f856c   1e46       MOVL         *-SP[6], ACC
003f856d   a044       MOVL         *-SP[4], XAR5
003f856e   a842       MOVL         *-SP[2], XAR4
003f856f   8a56       MOVL         XAR4, *-SP[22]
003f8570   767f       LCR          0x3f8adb
003f8571   8adb
003f8572   964d       MOV          *-SP[13], AL
003f8573   5200       CMPB         AL, #0x0
003f8574   ec03       SBF          3, EQ
003f8575   ffef       B            157, UNC
003f8576   009d
3f8577:              L1:
003f8577   284d       MOV          *-SP[13], #0x03e7
003f8578   03e7
003f8579   0642       MOVL         ACC, *-SP[2]
003f857a   0746       ADDL         ACC, *-SP[6]
003f857b   1901       SUBB         ACC, #1
003f857c   1e48       MOVL         *-SP[8], ACC
003f857d   c442       MOVL         XAR6, *-SP[2]
003f857e   8f3e       MOVL         XAR4, #0x3e8000
003f857f   8000
003f8580   a8a9       MOVL         ACC, XAR4
003f8581   0fa6       CMPL         ACC, XAR6
003f8582   660d       SB           13, HI
003f8583   c448       MOVL         XAR6, *-SP[8]
003f8584   8f3f       MOVL         XAR4, #0x3f7fff
003f8585   7fff
003f8586   a8a9       MOVL         ACC, XAR4
003f8587   0fa6       CMPL         ACC, XAR6
003f8588   6807       SB           7, LO
003f8589   0642       MOVL         ACC, *-SP[2]
003f858a   ff0f       SUB          ACC, #0x7d << 15
003f858b   007d
003f858c   1e4a       MOVL         *-SP[10], ACC
003f858d   2b4e       MOV          *-SP[14], #0
003f858e   6f16       SB           22, UNC
3f858f:              L2:
003f858f   c442       MOVL         XAR6, *-SP[2]
003f8590   8f3d       MOVL         XAR4, #0x3d7800
003f8591   7800
003f8592   a8a9       MOVL         ACC, XAR4
003f8593   0fa6       CMPL         ACC, XAR6
003f8594   660e       SB           14, HI
003f8595   c448       MOVL         XAR6, *-SP[8]
003f8596   8f3d       MOVL         XAR4, #0x3d7bff
003f8597   7bff
003f8598   a8a9       MOVL         ACC, XAR4
003f8599   0fa6       CMPL         ACC, XAR6
003f859a   6808       SB           8, LO
003f859b   0642       MOVL         ACC, *-SP[2]
003f859c   ff0b       SUB          ACC, #0x7af << 11
003f859d   07af
003f859e   1e4a       MOVL         *-SP[10], ACC
003f859f   284e       MOV          *-SP[14], #0x0010
003f85a0   0010
003f85a1   6f03       SB           3, UNC
3f85a2:              L3:
003f85a2   9a0c       MOVB         AL, #0xc
003f85a3   6f6f       SB           111, UNC
3f85a4:              L4:
003f85a4   767f       LCR          0x3f875d
003f85a5   875d
003f85a6   7622       EALLOW       
003f85a7   9a03       MOVB         AL, #0x3
003f85a8   f4a9       MOV          *(0:0x0a8d), AL
003f85a9   0a8d
003f85aa   761a       EDIS         
003f85ab   0201       MOVB         ACC, #1
003f85ac   1e50       MOVL         *-SP[16], ACC
003f85ad   0646       MOVL         ACC, *-SP[6]
003f85ae   0f50       CMPL         ACC, *-SP[16]
003f85af   685c       SB           92, LO
3f85b0:              L5:
003f85b0   5c4e       MOVZ         AR4, *-SP[14]
003f85b1   064a       MOVL         ACC, *-SP[10]
003f85b2   767f       LCR          0x3f87d4
003f85b3   87d4
003f85b4   964b       MOV          *-SP[11], AL
003f85b5   2b51       MOV          *-SP[17], #0
003f85b6   9251       MOV          AL, *-SP[17]
003f85b7   522d       CMPB         AL, #0x2d
003f85b8   6729       SB           41, HIS
3f85b9:              L6:
003f85b9   761f       MOVW         DP, #0xfe45
003f85ba   fe45
003f85bb   0600       MOVL         ACC, @0x0
003f85bc   be00       MOVB         XAR6, #0x00
003f85bd   0fa6       CMPL         ACC, XAR6
003f85be   ec03       SBF          3, EQ
003f85bf   c500       MOVL         XAR7, @0x0
003f85c0   3e67       LCR          *XAR7
3f85c1:              L7:
003f85c1   8a44       MOVL         XAR4, *-SP[4]
003f85c2   924b       MOV          AL, *-SP[11]
003f85c3   1ca9       XOR          AL, #0xffff
003f85c4   ffff
003f85c5   cec4       AND          AL, *+XAR4[0]
003f85c6   ec04       SBF          4, EQ
003f85c7   284d       MOV          *-SP[13], #0x001f
003f85c8   001f
003f85c9   6f18       SB           24, UNC
3f85ca:              L8:
003f85ca   8a44       MOVL         XAR4, *-SP[4]
003f85cb   92c4       MOV          AL, *+XAR4[0]
003f85cc   544b       CMP          AL, *-SP[11]
003f85cd   ec14       SBF          20, EQ
003f85ce   8a44       MOVL         XAR4, *-SP[4]
003f85cf   924b       MOV          AL, *-SP[11]
003f85d0   ff5e       NOT          AL
003f85d1   cac4       OR           AL, *+XAR4[0]
003f85d2   964c       MOV          *-SP[12], AL
003f85d3   5d4e       MOVZ         AR5, *-SP[14]
003f85d4   5c4c       MOVZ         AR4, *-SP[12]
003f85d5   064a       MOVL         ACC, *-SP[10]
003f85d6   767f       LCR          0x3f8811
003f85d7   8811
003f85d8   5c4e       MOVZ         AR4, *-SP[14]
003f85d9   064a       MOVL         ACC, *-SP[10]
003f85da   767f       LCR          0x3f87d4
003f85db   87d4
003f85dc   964b       MOV          *-SP[11], AL
003f85dd   0a51       INC          *-SP[17]
003f85de   9251       MOV          AL, *-SP[17]
003f85df   522d       CMPB         AL, #0x2d
003f85e0   68d9       SB           -39, LO
3f85e1:              L9:
003f85e1   8a44       MOVL         XAR4, *-SP[4]
003f85e2   92c4       MOV          AL, *+XAR4[0]
003f85e3   544b       CMP          AL, *-SP[11]
003f85e4   ec1b       SBF          27, EQ
003f85e5   1b4d       CMP          *-SP[13], #999
003f85e6   03e7
003f85e7   ed03       SBF          3, NEQ
003f85e8   284d       MOV          *-SP[13], #0x001e
003f85e9   001e
3f85ea:              L10:
003f85ea   8a56       MOVL         XAR4, *-SP[22]
003f85eb   924b       MOV          AL, *-SP[11]
003f85ec   96dc       MOV          *+XAR4[3], AL
003f85ed   8a44       MOVL         XAR4, *-SP[4]
003f85ee   92c4       MOV          AL, *+XAR4[0]
003f85ef   8a56       MOVL         XAR4, *-SP[22]
003f85f0   96d4       MOV          *+XAR4[2], AL
003f85f1   924e       MOV          AL, *-SP[14]
003f85f2   ed07       SBF          7, NEQ
003f85f3   8a56       MOVL         XAR4, *-SP[22]
003f85f4   064a       MOVL         ACC, *-SP[10]
003f85f5   ff1f       ADD          ACC, #0x7d << 15
003f85f6   007d
003f85f7   1ec4       MOVL         *+XAR4[0], ACC
003f85f8   6f13       SB           19, UNC
3f85f9:              L11:
003f85f9   8a56       MOVL         XAR4, *-SP[22]
003f85fa   064a       MOVL         ACC, *-SP[10]
003f85fb   ff1b       ADD          ACC, #0x7af << 11
003f85fc   07af
003f85fd   1ec4       MOVL         *+XAR4[0], ACC
003f85fe   6f0d       SB           13, UNC
3f85ff:              L12:
003f85ff   0644       MOVL         ACC, *-SP[4]
003f8600   0901       ADDB         ACC, #1
003f8601   1e44       MOVL         *-SP[4], ACC
003f8602   064a       MOVL         ACC, *-SP[10]
003f8603   0901       ADDB         ACC, #1
003f8604   1e4a       MOVL         *-SP[10], ACC
003f8605   0650       MOVL         ACC, *-SP[16]
003f8606   0901       ADDB         ACC, #1
003f8607   1e50       MOVL         *-SP[16], ACC
003f8608   0646       MOVL         ACC, *-SP[6]
003f8609   0f50       CMPL         ACC, *-SP[16]
003f860a   67a6       SB           -90, HIS
3f860b:              L13:
003f860b   767f       LCR          0x3f8750
003f860c   8750
003f860d   1b4d       CMP          *-SP[13], #999
003f860e   03e7
003f860f   ed02       SBF          2, NEQ
003f8610   2b4d       MOV          *-SP[13], #0
3f8611:              L14:
003f8611   924d       MOV          AL, *-SP[13]
3f8612:              L15:
003f8612   fe92       SUBB         SP, #18
003f8613   0006       LRETR        
3f8614:              _Flash2808_Erase:
003f8614   fe06       ADDB         SP, #6
003f8615   a844       MOVL         *-SP[4], XAR4
003f8616   9641       MOV          *-SP[1], AL
003f8617   8a44       MOVL         XAR4, *-SP[4]
003f8618   767f       LCR          0x3f8adb
003f8619   8adb
003f861a   9646       MOV          *-SP[6], AL
003f861b   5200       CMPB         AL, #0x0
003f861c   ec03       SBF          3, EQ
003f861d   ffef       B            151, UNC
003f861e   0097
3f861f:              L1:
003f861f   2846       MOV          *-SP[6], #0x03e7
003f8620   03e7
003f8621   1841       AND          *-SP[1], #0x000f
003f8622   000f
003f8623   9241       MOV          AL, *-SP[1]
003f8624   ed04       SBF          4, NEQ
003f8625   9a14       MOVB         AL, #0x14
003f8626   ffef       B            142, UNC
003f8627   008e
3f8628:              L2:
003f8628   767f       LCR          0x3f875d
003f8629   875d
003f862a   7622       EALLOW       
003f862b   9a03       MOVB         AL, #0x3
003f862c   f4a9       MOV          *(0:0x0a8d), AL
003f862d   0a8d
003f862e   761a       EDIS         
003f862f   2b45       MOV          *-SP[5], #0
003f8630   9245       MOV          AL, *-SP[5]
003f8631   5203       CMPB         AL, #0x3
003f8632   6616       SB           22, HI
3f8633:              L3:
003f8633   0e45       MOVU         ACC, *-SP[5]
003f8634   8f3f       MOVL         XAR4, #0x3f9150
003f8635   9150
003f8636   ff31       LSL          ACC, 2
003f8637   5601       ADDL         XAR4, ACC
003f8638   00a4
003f8639   8344       MOVL         XAR5, *-SP[4]
003f863a   8ac4       MOVL         XAR4, *+XAR4[0]
003f863b   9a80       MOVB         AL, #0x80
003f863c   767f       LCR          0x3f892b
003f863d   892b
003f863e   9646       MOV          *-SP[6], AL
003f863f   5200       CMPB         AL, #0x0
003f8640   ec04       SBF          4, EQ
003f8641   2846       MOV          *-SP[6], #0x0018
003f8642   0018
003f8643   6f05       SB           5, UNC
3f8644:              L4:
003f8644   0a45       INC          *-SP[5]
003f8645   9245       MOV          AL, *-SP[5]
003f8646   5203       CMPB         AL, #0x3
003f8647   69ec       SB           -20, LOS
3f8648:              L5:
003f8648   9246       MOV          AL, *-SP[6]
003f8649   ed5d       SBF          93, NEQ
003f864a   2b45       MOV          *-SP[5], #0
003f864b   9245       MOV          AL, *-SP[5]
003f864c   5203       CMPB         AL, #0x3
003f864d   6659       SB           89, HI
3f864e:              L6:
003f864e   5845       MOVZ         AR0, *-SP[5]
003f864f   8f3f       MOVL         XAR4, #0x3f914c
003f8650   914c
003f8651   9294       MOV          AL, *+XAR4[AR0]
003f8652   ce41       AND          AL, *-SP[1]
003f8653   ec4d       SBF          77, EQ
003f8654   0e45       MOVU         ACC, *-SP[5]
003f8655   8f3f       MOVL         XAR4, #0x3f9150
003f8656   9150
003f8657   8f7f       MOVL         XAR5, #0x3f9152
003f8658   9152
003f8659   ff31       LSL          ACC, 2
003f865a   5601       ADDL         XAR4, ACC
003f865b   00a4
003f865c   0e45       MOVU         ACC, *-SP[5]
003f865d   ff31       LSL          ACC, 2
003f865e   5601       ADDL         XAR5, ACC
003f865f   00a5
003f8660   8ac4       MOVL         XAR4, *+XAR4[0]
003f8661   92c5       MOV          AL, *+XAR5[0]
003f8662   8344       MOVL         XAR5, *-SP[4]
003f8663   767f       LCR          0x3f8a4b
003f8664   8a4b
003f8665   9646       MOV          *-SP[6], AL
003f8666   5200       CMPB         AL, #0x0
003f8667   ed13       SBF          19, NEQ
003f8668   0e45       MOVU         ACC, *-SP[5]
003f8669   8f3f       MOVL         XAR4, #0x3f9150
003f866a   9150
003f866b   8f7f       MOVL         XAR5, #0x3f9152
003f866c   9152
003f866d   ff31       LSL          ACC, 2
003f866e   5601       ADDL         XAR4, ACC
003f866f   00a4
003f8670   0e45       MOVU         ACC, *-SP[5]
003f8671   ff31       LSL          ACC, 2
003f8672   5601       ADDL         XAR5, ACC
003f8673   00a5
003f8674   8ac4       MOVL         XAR4, *+XAR4[0]
003f8675   92c5       MOV          AL, *+XAR5[0]
003f8676   8344       MOVL         XAR5, *-SP[4]
003f8677   767f       LCR          0x3f88d0
003f8678   88d0
003f8679   9646       MOV          *-SP[6], AL
3f867a:              L7:
003f867a   5200       CMPB         AL, #0x0
003f867b   ed14       SBF          20, NEQ
003f867c   0e45       MOVU         ACC, *-SP[5]
003f867d   8f3f       MOVL         XAR4, #0x3f9150
003f867e   9150
003f867f   8f7f       MOVL         XAR5, #0x3f9152
003f8680   9152
003f8681   ff31       LSL          ACC, 2
003f8682   5601       ADDL         XAR4, ACC
003f8683   00a4
003f8684   0e45       MOVU         ACC, *-SP[5]
003f8685   ff31       LSL          ACC, 2
003f8686   5601       ADDL         XAR5, ACC
003f8687   00a5
003f8688   8ac4       MOVL         XAR4, *+XAR4[0]
003f8689   92c5       MOV          AL, *+XAR5[0]
003f868a   8344       MOVL         XAR5, *-SP[4]
003f868b   767f       LCR          0x3f892b
003f868c   892b
003f868d   9646       MOV          *-SP[6], AL
003f868e   6f12       SB           18, UNC
3f868f:              L8:
003f868f   0e45       MOVU         ACC, *-SP[5]
003f8690   8f3f       MOVL         XAR4, #0x3f9150
003f8691   9150
003f8692   8f7f       MOVL         XAR5, #0x3f9152
003f8693   9152
003f8694   ff31       LSL          ACC, 2
003f8695   5601       ADDL         XAR4, ACC
003f8696   00a4
003f8697   0e45       MOVU         ACC, *-SP[5]
003f8698   ff31       LSL          ACC, 2
003f8699   5601       ADDL         XAR5, ACC
003f869a   00a5
003f869b   8ac4       MOVL         XAR4, *+XAR4[0]
003f869c   92c5       MOV          AL, *+XAR5[0]
003f869d   8344       MOVL         XAR5, *-SP[4]
003f869e   767f       LCR          0x3f892b
003f869f   892b
3f86a0:              L9:
003f86a0   9246       MOV          AL, *-SP[6]
003f86a1   ed05       SBF          5, NEQ
003f86a2   0a45       INC          *-SP[5]
003f86a3   9245       MOV          AL, *-SP[5]
003f86a4   5203       CMPB         AL, #0x3
003f86a5   69a9       SB           -87, LOS
3f86a6:              L10:
003f86a6   9246       MOV          AL, *-SP[6]
003f86a7   ec0a       SBF          10, EQ
003f86a8   0e45       MOVU         ACC, *-SP[5]
003f86a9   8f3f       MOVL         XAR4, #0x3f9150
003f86aa   9150
003f86ab   ff31       LSL          ACC, 2
003f86ac   5601       ADDL         XAR4, ACC
003f86ad   00a4
003f86ae   06c4       MOVL         ACC, *+XAR4[0]
003f86af   8a44       MOVL         XAR4, *-SP[4]
003f86b0   1ec4       MOVL         *+XAR4[0], ACC
3f86b1:              L11:
003f86b1   767f       LCR          0x3f8750
003f86b2   8750
003f86b3   9246       MOV          AL, *-SP[6]
3f86b4:              L12:
003f86b4   fe86       SUBB         SP, #6
003f86b5   0006       LRETR        
3f86b6:              _Fl28x_EraseVerify:
003f86b6   fe08       ADDB         SP, #8
003f86b7   7c43       MOV          *-SP[3], AR4
003f86b8   1e42       MOVL         *-SP[2], ACC
003f86b9   767f       LCR          0x3f8b4d
003f86ba   8b4d
003f86bb   9647       MOV          *-SP[7], AL
003f86bc   767f       LCR          0x3f8b88
003f86bd   8b88
003f86be   9646       MOV          *-SP[6], AL
003f86bf   0642       MOVL         ACC, *-SP[2]
003f86c0   767f       LCR          0x3f87a1
003f86c1   87a1
003f86c2   9645       MOV          *-SP[5], AL
003f86c3   9a03       MOVB         AL, #0x3
003f86c4   f4a9       MOV          *(0:0x0a91), AL
003f86c5   0a91
003f86c6   9a0a       MOVB         AL, #0xa
003f86c7   f4a9       MOV          *(0:0x0a8c), AL
003f86c8   0a8c
003f86c9   9a00       MOVB         AL, #0x0
003f86ca   9b02       MOVB         AH, #0x2
003f86cb   767f       LCR          0x3f8b6a
003f86cc   8b6a
003f86cd   9243       MOV          AL, *-SP[3]
003f86ce   1aa9       OR           AL, #0x0a0b
003f86cf   0a0b
003f86d0   f4a9       MOV          *(0:0x0a90), AL
003f86d1   0a90
003f86d2   ff20       MOV          ACC, #6553
003f86d3   1999
003f86d4   767f       LCR          0x3f8b6a
003f86d5   8b6a
003f86d6   9243       MOV          AL, *-SP[3]
003f86d7   1aa9       OR           AL, #0x020b
003f86d8   020b
003f86d9   f4a9       MOV          *(0:0x0a90), AL
003f86da   0a90
003f86db   ff2f       MOV          ACC, #0x1 << 15
003f86dc   0001
003f86dd   767f       LCR          0x3f8b6a
003f86de   8b6a
003f86df   5845       MOVZ         AR0, *-SP[5]
003f86e0   8f00       MOVL         XAR4, #0x000a9c
003f86e1   0a9c
003f86e2   9294       MOV          AL, *+XAR4[AR0]
003f86e3   9644       MOV          *-SP[4], AL
003f86e4   9243       MOV          AL, *-SP[3]
003f86e5   1aa9       OR           AL, #0x0a0b
003f86e6   0a0b
003f86e7   f4a9       MOV          *(0:0x0a90), AL
003f86e8   0a90
003f86e9   9a00       MOVB         AL, #0x0
003f86ea   9b01       MOVB         AH, #0x1
003f86eb   767f       LCR          0x3f8b6a
003f86ec   8b6a
003f86ed   28a9       MOV          AL, #0x0a0f
003f86ee   0a0f
003f86ef   f4a9       MOV          *(0:0x0a90), AL
003f86f0   0a90
003f86f1   ff20       MOV          ACC, #6553
003f86f2   1999
003f86f3   767f       LCR          0x3f8b6a
003f86f4   8b6a
003f86f5   761a       EDIS         
003f86f6   9246       MOV          AL, *-SP[6]
003f86f7   767f       LCR          0x3f8b8c
003f86f8   8b8c
003f86f9   f447       MOV          *(0:0x7077), *-SP[7]
003f86fa   7077
003f86fb   9244       MOV          AL, *-SP[4]
003f86fc   fe88       SUBB         SP, #8
003f86fd   0006       LRETR        
3f86fe:              _Fl28x_ErasePulse:
003f86fe   fe08       ADDB         SP, #8
003f86ff   7d44       MOV          *-SP[4], AR5
003f8700   7c43       MOV          *-SP[3], AR4
003f8701   1e42       MOVL         *-SP[2], ACC
003f8702   767f       LCR          0x3f8b4d
003f8703   8b4d
003f8704   9647       MOV          *-SP[7], AL
003f8705   767f       LCR          0x3f8b88
003f8706   8b88
003f8707   9646       MOV          *-SP[6], AL
003f8708   0642       MOVL         ACC, *-SP[2]
003f8709   767f       LCR          0x3f87a1
003f870a   87a1
003f870b   9a04       MOVB         AL, #0x4
003f870c   f4a9       MOV          *(0:0x0a91), AL
003f870d   0a91
003f870e   9a06       MOVB         AL, #0x6
003f870f   f4a9       MOV          *(0:0x0a8b), AL
003f8710   0a8b
003f8711   9a0b       MOVB         AL, #0xb
003f8712   f4a9       MOV          *(0:0x0a89), AL
003f8713   0a89
003f8714   9a03       MOVB         AL, #0x3
003f8715   f4a9       MOV          *(0:0x0a8c), AL
003f8716   0a8c
003f8717   f443       MOV          *(0:0x0a8a), *-SP[3]
003f8718   0a8a
003f8719   9a00       MOVB         AL, #0x0
003f871a   9b02       MOVB         AH, #0x2
003f871b   767f       LCR          0x3f8b6a
003f871c   8b6a
003f871d   9244       MOV          AL, *-SP[4]
003f871e   1aa9       OR           AL, #0x0a0b
003f871f   0a0b
003f8720   f4a9       MOV          *(0:0x0a90), AL
003f8721   0a90
003f8722   2b45       MOV          *-SP[5], #0
003f8723   9243       MOV          AL, *-SP[3]
003f8724   5445       CMP          AL, *-SP[5]
003f8725   6809       SB           9, LO
3f8726:              L1:
003f8726   9a00       MOVB         AL, #0x0
003f8727   9b02       MOVB         AH, #0x2
003f8728   767f       LCR          0x3f8b6a
003f8729   8b6a
003f872a   0a45       INC          *-SP[5]
003f872b   9243       MOV          AL, *-SP[3]
003f872c   5445       CMP          AL, *-SP[5]
003f872d   67f9       SB           -7, HIS
3f872e:              L2:
003f872e   9244       MOV          AL, *-SP[4]
003f872f   1aa9       OR           AL, #0x020b
003f8730   020b
003f8731   f4a9       MOV          *(0:0x0a90), AL
003f8732   0a90
003f8733   ff2f       MOV          ACC, #0x1518 << 15
003f8734   1518
003f8735   767f       LCR          0x3f8b6a
003f8736   8b6a
003f8737   9244       MOV          AL, *-SP[4]
003f8738   1aa9       OR           AL, #0x0a0b
003f8739   0a0b
003f873a   f4a9       MOV          *(0:0x0a90), AL
003f873b   0a90
003f873c   9a00       MOVB         AL, #0x0
003f873d   9b28       MOVB         AH, #0x28
003f873e   767f       LCR          0x3f8b6a
003f873f   8b6a
003f8740   28a9       MOV          AL, #0x0a0f
003f8741   0a0f
003f8742   f4a9       MOV          *(0:0x0a90), AL
003f8743   0a90
003f8744   ff20       MOV          ACC, #6553
003f8745   1999
003f8746   767f       LCR          0x3f8b6a
003f8747   8b6a
003f8748   761a       EDIS         
003f8749   9246       MOV          AL, *-SP[6]
003f874a   767f       LCR          0x3f8b8c
003f874b   8b8c
003f874c   f447       MOV          *(0:0x7077), *-SP[7]
003f874d   7077
003f874e   fe88       SUBB         SP, #8
003f874f   0006       LRETR        
3f8750:              _Fl28x_LeaveCmdMode:
003f8750   7622       EALLOW       
003f8751   767f       LCR          0x3f8782
003f8752   8782
003f8753   9a00       MOVB         AL, #0x0
003f8754   f4a9       MOV          *(0:0x0a81), AL
003f8755   0a81
003f8756   f5a9       MOV          AL, *(0:0x0a90)
003f8757   0a90
003f8758   f004       XORB         AL, #0x4
003f8759   f4a9       MOV          *(0:0x0a90), AL
003f875a   0a90
003f875b   761a       EDIS         
003f875c   0006       LRETR        
3f875d:              _Fl28x_EnterCmdMode:
003f875d   7622       EALLOW       
003f875e   9a00       MOVB         AL, #0x0
003f875f   f4a9       MOV          *(0:0x0a82), AL
003f8760   0a82
003f8761   767f       LCR          0x3f8782
003f8762   8782
003f8763   28a9       MOV          AL, #0xaa55
003f8764   aa55
003f8765   f4a9       MOV          *(0:0x0a81), AL
003f8766   0a81
003f8767   28a9       MOV          AL, #0x0e0d
003f8768   0e0d
003f8769   f4a9       MOV          *(0:0x0a90), AL
003f876a   0a90
003f876b   9a00       MOVB         AL, #0x0
003f876c   9b03       MOVB         AH, #0x3
003f876d   767f       LCR          0x3f8b6a
003f876e   8b6a
003f876f   761f       MOVW         DP, #0xfe45
003f8770   fe45
003f8771   0600       MOVL         ACC, @0x0
003f8772   be00       MOVB         XAR6, #0x00
003f8773   0fa6       CMPL         ACC, XAR6
003f8774   ec03       SBF          3, EQ
003f8775   c500       MOVL         XAR7, @0x0
003f8776   3e67       LCR          *XAR7
3f8777:              L1:
003f8777   28a9       MOV          AL, #0x0a0f
003f8778   0a0f
003f8779   f4a9       MOV          *(0:0x0a90), AL
003f877a   0a90
003f877b   28a9       MOV          AL, #0x4ccc
003f877c   4ccc
003f877d   9b03       MOVB         AH, #0x3
003f877e   767f       LCR          0x3f8b6a
003f877f   8b6a
003f8780   761a       EDIS         
003f8781   0006       LRETR        
3f8782:              _Fl28x_FlashRegSleep:
003f8782   9a00       MOVB         AL, #0x0
003f8783   f4a9       MOV          *(0:0x0a91), AL
003f8784   0a91
003f8785   f4a9       MOV          *(0:0x0a94), AL
003f8786   0a94
003f8787   f4a9       MOV          *(0:0x0a98), AL
003f8788   0a98
003f8789   f4a9       MOV          *(0:0x0a99), AL
003f878a   0a99
003f878b   f4a9       MOV          *(0:0x0a9a), AL
003f878c   0a9a
003f878d   f4a9       MOV          *(0:0x0a9b), AL
003f878e   0a9b
003f878f   f4a9       MOV          *(0:0x0a92), AL
003f8790   0a92
003f8791   f4a9       MOV          *(0:0x0a89), AL
003f8792   0a89
003f8793   f4a9       MOV          *(0:0x0a8a), AL
003f8794   0a8a
003f8795   f4a9       MOV          *(0:0x0a8b), AL
003f8796   0a8b
003f8797   f4a9       MOV          *(0:0x0a8c), AL
003f8798   0a8c
003f8799   9a0a       MOVB         AL, #0xa
003f879a   f4a9       MOV          *(0:0x0a88), AL
003f879b   0a88
003f879c   28a9       MOV          AL, #0x0c0c
003f879d   0c0c
003f879e   f4a9       MOV          *(0:0x0a90), AL
003f879f   0a90
003f87a0   0006       LRETR        
3f87a1:              _Fl28x_OpenPulse:
003f87a1   fe02       ADDB         SP, #2
003f87a2   1e42       MOVL         *-SP[2], ACC
003f87a3   7622       EALLOW       
003f87a4   28a9       MOV          AL, #0x0a0f
003f87a5   0a0f
003f87a6   f4a9       MOV          *(0:0x0a90), AL
003f87a7   0a90
003f87a8   8f00       MOVL         XAR4, #0x000a94
003f87a9   0a94
003f87aa   2901       CLRC         SXM
003f87ab   0642       MOVL         ACC, *-SP[2]
003f87ac   ff40       SFR          ACC, 1
003f87ad   96c4       MOV          *+XAR4[0], AL
003f87ae   0642       MOVL         ACC, *-SP[2]
003f87af   9003       ANDB         AL, #0x3
003f87b0   fe82       SUBB         SP, #2
003f87b1   0006       LRETR        
3f87b2:              _Fl28x_ClosePulse:
003f87b2   7622       EALLOW       
003f87b3   9a00       MOVB         AL, #0x0
003f87b4   f4a9       MOV          *(0:0x0a91), AL
003f87b5   0a91
003f87b6   28a9       MOV          AL, #0x0a0f
003f87b7   0a0f
003f87b8   f4a9       MOV          *(0:0x0a90), AL
003f87b9   0a90
003f87ba   9a00       MOVB         AL, #0x0
003f87bb   f4a9       MOV          *(0:0x0a89), AL
003f87bc   0a89
003f87bd   f4a9       MOV          *(0:0x0a8a), AL
003f87be   0a8a
003f87bf   f4a9       MOV          *(0:0x0a8b), AL
003f87c0   0a8b
003f87c1   f4a9       MOV          *(0:0x0a8c), AL
003f87c2   0a8c
003f87c3   ff20       MOV          ACC, #6553
003f87c4   1999
003f87c5   767f       LCR          0x3f8b6a
003f87c6   8b6a
003f87c7   761a       EDIS         
003f87c8   0006       LRETR        
3f87c9:              _Fl28x_MaskAll:
003f87c9   28a9       MOV          AL, #0xffff
003f87ca   ffff
003f87cb   f4a9       MOV          *(0:0x0a98), AL
003f87cc   0a98
003f87cd   f4a9       MOV          *(0:0x0a99), AL
003f87ce   0a99
003f87cf   f4a9       MOV          *(0:0x0a9a), AL
003f87d0   0a9a
003f87d1   f4a9       MOV          *(0:0x0a9b), AL
003f87d2   0a9b
003f87d3   0006       LRETR        
3f87d4:              _Fl28x_ProgVerify:
003f87d4   fe08       ADDB         SP, #8
003f87d5   7c43       MOV          *-SP[3], AR4
003f87d6   1e42       MOVL         *-SP[2], ACC
003f87d7   767f       LCR          0x3f8b4d
003f87d8   8b4d
003f87d9   9647       MOV          *-SP[7], AL
003f87da   767f       LCR          0x3f8b88
003f87db   8b88
003f87dc   9646       MOV          *-SP[6], AL
003f87dd   0642       MOVL         ACC, *-SP[2]
003f87de   767f       LCR          0x3f87a1
003f87df   87a1
003f87e0   9644       MOV          *-SP[4], AL
003f87e1   9243       MOV          AL, *-SP[3]
003f87e2   1aa9       OR           AL, #0x0a0b
003f87e3   0a0b
003f87e4   f4a9       MOV          *(0:0x0a90), AL
003f87e5   0a90
003f87e6   9a01       MOVB         AL, #0x1
003f87e7   f4a9       MOV          *(0:0x0a91), AL
003f87e8   0a91
003f87e9   9a04       MOVB         AL, #0x4
003f87ea   f4a9       MOV          *(0:0x0a89), AL
003f87eb   0a89
003f87ec   ff20       MOV          ACC, #6553
003f87ed   1999
003f87ee   767f       LCR          0x3f8b6a
003f87ef   8b6a
003f87f0   9243       MOV          AL, *-SP[3]
003f87f1   1aa9       OR           AL, #0x020b
003f87f2   020b
003f87f3   f4a9       MOV          *(0:0x0a90), AL
003f87f4   0a90
003f87f5   ff22       MOV          ACC, #0x3333 << 2
003f87f6   3333
003f87f7   767f       LCR          0x3f8b6a
003f87f8   8b6a
003f87f9   5844       MOVZ         AR0, *-SP[4]
003f87fa   8f00       MOVL         XAR4, #0x000a9c
003f87fb   0a9c
003f87fc   9294       MOV          AL, *+XAR4[AR0]
003f87fd   9645       MOV          *-SP[5], AL
003f87fe   9243       MOV          AL, *-SP[3]
003f87ff   1aa9       OR           AL, #0x0a0b
003f8800   0a0b
003f8801   f4a9       MOV          *(0:0x0a90), AL
003f8802   0a90
003f8803   9a00       MOVB         AL, #0x0
003f8804   9b01       MOVB         AH, #0x1
003f8805   767f       LCR          0x3f8b6a
003f8806   8b6a
003f8807   767f       LCR          0x3f87b2
003f8808   87b2
003f8809   9246       MOV          AL, *-SP[6]
003f880a   767f       LCR          0x3f8b8c
003f880b   8b8c
003f880c   f447       MOV          *(0:0x7077), *-SP[7]
003f880d   7077
003f880e   9245       MOV          AL, *-SP[5]
003f880f   fe88       SUBB         SP, #8
003f8810   0006       LRETR        
3f8811:              _Fl28x_ProgPulse:
003f8811   fe08       ADDB         SP, #8
003f8812   7d44       MOV          *-SP[4], AR5
003f8813   7c43       MOV          *-SP[3], AR4
003f8814   1e42       MOVL         *-SP[2], ACC
003f8815   767f       LCR          0x3f8b4d
003f8816   8b4d
003f8817   9647       MOV          *-SP[7], AL
003f8818   767f       LCR          0x3f8b88
003f8819   8b88
003f881a   9646       MOV          *-SP[6], AL
003f881b   0642       MOVL         ACC, *-SP[2]
003f881c   767f       LCR          0x3f87a1
003f881d   87a1
003f881e   9645       MOV          *-SP[5], AL
003f881f   767f       LCR          0x3f87c9
003f8820   87c9
003f8821   5845       MOVZ         AR0, *-SP[5]
003f8822   8f00       MOVL         XAR4, #0x000a98
003f8823   0a98
003f8824   9243       MOV          AL, *-SP[3]
003f8825   9694       MOV          *+XAR4[AR0], AL
003f8826   9244       MOV          AL, *-SP[4]
003f8827   1aa9       OR           AL, #0x0a0b
003f8828   0a0b
003f8829   f4a9       MOV          *(0:0x0a90), AL
003f882a   0a90
003f882b   9a02       MOVB         AL, #0x2
003f882c   f4a9       MOV          *(0:0x0a91), AL
003f882d   0a91
003f882e   9a09       MOVB         AL, #0x9
003f882f   f4a9       MOV          *(0:0x0a89), AL
003f8830   0a89
003f8831   9a06       MOVB         AL, #0x6
003f8832   f4a9       MOV          *(0:0x0a8b), AL
003f8833   0a8b
003f8834   ff20       MOV          ACC, #6553
003f8835   1999
003f8836   767f       LCR          0x3f8b6a
003f8837   8b6a
003f8838   9244       MOV          AL, *-SP[4]
003f8839   1aa9       OR           AL, #0x020b
003f883a   020b
003f883b   f4a9       MOV          *(0:0x0a90), AL
003f883c   0a90
003f883d   9a00       MOVB         AL, #0x0
003f883e   9b04       MOVB         AH, #0x4
003f883f   767f       LCR          0x3f8b6a
003f8840   8b6a
003f8841   9244       MOV          AL, *-SP[4]
003f8842   1aa9       OR           AL, #0x0a0b
003f8843   0a0b
003f8844   f4a9       MOV          *(0:0x0a90), AL
003f8845   0a90
003f8846   9a00       MOVB         AL, #0x0
003f8847   9b01       MOVB         AH, #0x1
003f8848   767f       LCR          0x3f8b6a
003f8849   8b6a
003f884a   767f       LCR          0x3f87b2
003f884b   87b2
003f884c   9246       MOV          AL, *-SP[6]
003f884d   767f       LCR          0x3f8b8c
003f884e   8b8c
003f884f   f447       MOV          *(0:0x7077), *-SP[7]
003f8850   7077
003f8851   fe88       SUBB         SP, #8
003f8852   0006       LRETR        
3f8853:              _Fl28x_CompactVerify:
003f8853   fe08       ADDB         SP, #8
003f8854   7c43       MOV          *-SP[3], AR4
003f8855   1e42       MOVL         *-SP[2], ACC
003f8856   767f       LCR          0x3f8b4d
003f8857   8b4d
003f8858   9647       MOV          *-SP[7], AL
003f8859   767f       LCR          0x3f8b88
003f885a   8b88
003f885b   9646       MOV          *-SP[6], AL
003f885c   0642       MOVL         ACC, *-SP[2]
003f885d   767f       LCR          0x3f87a1
003f885e   87a1
003f885f   9645       MOV          *-SP[5], AL
003f8860   9243       MOV          AL, *-SP[3]
003f8861   1aa9       OR           AL, #0x0a0b
003f8862   0a0b
003f8863   f4a9       MOV          *(0:0x0a90), AL
003f8864   0a90
003f8865   9a05       MOVB         AL, #0x5
003f8866   f4a9       MOV          *(0:0x0a91), AL
003f8867   0a91
003f8868   ff20       MOV          ACC, #6553
003f8869   1999
003f886a   767f       LCR          0x3f8b6a
003f886b   8b6a
003f886c   9243       MOV          AL, *-SP[3]
003f886d   1aa9       OR           AL, #0x020b
003f886e   020b
003f886f   f4a9       MOV          *(0:0x0a90), AL
003f8870   0a90
003f8871   9a00       MOVB         AL, #0x0
003f8872   9b08       MOVB         AH, #0x8
003f8873   767f       LCR          0x3f8b6a
003f8874   8b6a
003f8875   5845       MOVZ         AR0, *-SP[5]
003f8876   8f00       MOVL         XAR4, #0x000a9c
003f8877   0a9c
003f8878   9294       MOV          AL, *+XAR4[AR0]
003f8879   9644       MOV          *-SP[4], AL
003f887a   9243       MOV          AL, *-SP[3]
003f887b   1aa9       OR           AL, #0x0a0b
003f887c   0a0b
003f887d   f4a9       MOV          *(0:0x0a90), AL
003f887e   0a90
003f887f   ff20       MOV          ACC, #6553
003f8880   1999
003f8881   767f       LCR          0x3f8b6a
003f8882   8b6a
003f8883   767f       LCR          0x3f87b2
003f8884   87b2
003f8885   9246       MOV          AL, *-SP[6]
003f8886   767f       LCR          0x3f8b8c
003f8887   8b8c
003f8888   f447       MOV          *(0:0x7077), *-SP[7]
003f8889   7077
003f888a   9244       MOV          AL, *-SP[4]
003f888b   fe88       SUBB         SP, #8
003f888c   0006       LRETR        
3f888d:              _Fl28x_CompactPulse:
003f888d   fe08       ADDB         SP, #8
003f888e   7d44       MOV          *-SP[4], AR5
003f888f   7c43       MOV          *-SP[3], AR4
003f8890   1e42       MOVL         *-SP[2], ACC
003f8891   767f       LCR          0x3f8b4d
003f8892   8b4d
003f8893   9647       MOV          *-SP[7], AL
003f8894   767f       LCR          0x3f8b88
003f8895   8b88
003f8896   9646       MOV          *-SP[6], AL
003f8897   0642       MOVL         ACC, *-SP[2]
003f8898   767f       LCR          0x3f87a1
003f8899   87a1
003f889a   9645       MOV          *-SP[5], AL
003f889b   767f       LCR          0x3f87c9
003f889c   87c9
003f889d   5845       MOVZ         AR0, *-SP[5]
003f889e   8f00       MOVL         XAR4, #0x000a98
003f889f   0a98
003f88a0   9243       MOV          AL, *-SP[3]
003f88a1   9694       MOV          *+XAR4[AR0], AL
003f88a2   9244       MOV          AL, *-SP[4]
003f88a3   1aa9       OR           AL, #0x0a0b
003f88a4   0a0b
003f88a5   f4a9       MOV          *(0:0x0a90), AL
003f88a6   0a90
003f88a7   9a06       MOVB         AL, #0x6
003f88a8   f4a9       MOV          *(0:0x0a91), AL
003f88a9   0a91
003f88aa   f4a9       MOV          *(0:0x0a8b), AL
003f88ab   0a8b
003f88ac   f4a9       MOV          *(0:0x0a89), AL
003f88ad   0a89
003f88ae   9a00       MOVB         AL, #0x0
003f88af   f4a9       MOV          *(0:0x0a8c), AL
003f88b0   0a8c
003f88b1   9a00       MOVB         AL, #0x0
003f88b2   9b0a       MOVB         AH, #0xa
003f88b3   767f       LCR          0x3f8b6a
003f88b4   8b6a
003f88b5   9244       MOV          AL, *-SP[4]
003f88b6   1aa9       OR           AL, #0x020b
003f88b7   020b
003f88b8   f4a9       MOV          *(0:0x0a90), AL
003f88b9   0a90
003f88ba   ff2f       MOV          ACC, #0x3e8 << 15
003f88bb   03e8
003f88bc   767f       LCR          0x3f8b6a
003f88bd   8b6a
003f88be   9244       MOV          AL, *-SP[4]
003f88bf   1aa9       OR           AL, #0x0a0b
003f88c0   0a0b
003f88c1   f4a9       MOV          *(0:0x0a90), AL
003f88c2   0a90
003f88c3   9a00       MOVB         AL, #0x0
003f88c4   9b01       MOVB         AH, #0x1
003f88c5   767f       LCR          0x3f8b6a
003f88c6   8b6a
003f88c7   767f       LCR          0x3f87b2
003f88c8   87b2
003f88c9   9246       MOV          AL, *-SP[6]
003f88ca   767f       LCR          0x3f8b8c
003f88cb   8b8c
003f88cc   f447       MOV          *(0:0x7077), *-SP[7]
003f88cd   7077
003f88ce   fe88       SUBB         SP, #8
003f88cf   0006       LRETR        
3f88d0:              _Fl2808_EraseSector:
003f88d0   fe10       ADDB         SP, #16
003f88d1   a046       MOVL         *-SP[6], XAR5
003f88d2   9643       MOV          *-SP[3], AL
003f88d3   a842       MOVL         *-SP[2], XAR4
003f88d4   c442       MOVL         XAR6, *-SP[2]
003f88d5   8f3e       MOVL         XAR4, #0x3e8000
003f88d6   8000
003f88d7   a8a9       MOVL         ACC, XAR4
003f88d8   0fa6       CMPL         ACC, XAR6
003f88d9   6611       SB           17, HI
003f88da   8043       MOVZ         AR7, *-SP[3]
003f88db   0642       MOVL         ACC, *-SP[2]
003f88dc   0da7       ADDU         ACC, AR7
003f88dd   1ea6       MOVL         XAR6, ACC
003f88de   8f3f       MOVL         XAR4, #0x3f7fff
003f88df   7fff
003f88e0   de81       SUBB         XAR6, #1
003f88e1   a8a9       MOVL         ACC, XAR4
003f88e2   0fa6       CMPL         ACC, XAR6
003f88e3   6807       SB           7, LO
003f88e4   0642       MOVL         ACC, *-SP[2]
003f88e5   ff0f       SUB          ACC, #0x7d << 15
003f88e6   007d
003f88e7   1e50       MOVL         *-SP[16], ACC
003f88e8   2b4d       MOV          *-SP[13], #0
003f88e9   6f03       SB           3, UNC
3f88ea:              L1:
003f88ea   9a0c       MOVB         AL, #0xc
003f88eb   6f3e       SB           62, UNC
3f88ec:              L2:
003f88ec   2849       MOV          *-SP[9], #0x0016
003f88ed   0016
003f88ee   2b48       MOV          *-SP[8], #0
003f88ef   2b4b       MOV          *-SP[11], #0
003f88f0   2b4a       MOV          *-SP[10], #0
003f88f1   2b4c       MOV          *-SP[12], #0
3f88f2:              L3:
003f88f2   5c4d       MOVZ         AR4, *-SP[13]
003f88f3   0650       MOVL         ACC, *-SP[16]
003f88f4   767f       LCR          0x3f86b6
003f88f5   86b6
003f88f6   9647       MOV          *-SP[7], AL
003f88f7   761f       MOVW         DP, #0xfe45
003f88f8   fe45
003f88f9   0600       MOVL         ACC, @0x0
003f88fa   be00       MOVB         XAR6, #0x00
003f88fb   0fa6       CMPL         ACC, XAR6
003f88fc   ec03       SBF          3, EQ
003f88fd   c500       MOVL         XAR7, @0x0
003f88fe   3e67       LCR          *XAR7
3f88ff:              L4:
003f88ff   1b47       CMP          *-SP[7], #-1
003f8900   ffff
003f8901   ec17       SBF          23, EQ
003f8902   1b4a       CMP          *-SP[10], #5000
003f8903   1388
003f8904   6804       SB           4, LO
003f8905   2849       MOV          *-SP[9], #0x0016
003f8906   0016
003f8907   6f18       SB           24, UNC
3f8908:              L5:
003f8908   5c48       MOVZ         AR4, *-SP[8]
003f8909   5d4d       MOVZ         AR5, *-SP[13]
003f890a   0650       MOVL         ACC, *-SP[16]
003f890b   767f       LCR          0x3f86fe
003f890c   86fe
003f890d   0a4b       INC          *-SP[11]
003f890e   0a4a       INC          *-SP[10]
003f890f   9248       MOV          AL, *-SP[8]
003f8910   520a       CMPB         AL, #0xa
003f8911   670b       SB           11, HIS
003f8912   924b       MOV          AL, *-SP[11]
003f8913   520f       CMPB         AL, #0xf
003f8914   6808       SB           8, LO
003f8915   2b4b       MOV          *-SP[11], #0
003f8916   0a48       INC          *-SP[8]
003f8917   6f05       SB           5, UNC
3f8918:              L6:
003f8918   0a4c       INC          *-SP[12]
003f8919   0650       MOVL         ACC, *-SP[16]
003f891a   0901       ADDB         ACC, #1
003f891b   1e50       MOVL         *-SP[16], ACC
3f891c:              L7:
003f891c   9243       MOV          AL, *-SP[3]
003f891d   544c       CMP          AL, *-SP[12]
003f891e   66d4       SB           -44, HI
3f891f:              L8:
003f891f   767f       LCR          0x3f87b2
003f8920   87b2
003f8921   9243       MOV          AL, *-SP[3]
003f8922   544c       CMP          AL, *-SP[12]
003f8923   ed05       SBF          5, NEQ
003f8924   1b47       CMP          *-SP[7], #-1
003f8925   ffff
003f8926   ed02       SBF          2, NEQ
003f8927   2b49       MOV          *-SP[9], #0
3f8928:              L9:
003f8928   9249       MOV          AL, *-SP[9]
3f8929:              L10:
003f8929   fe90       SUBB         SP, #16
003f892a   0006       LRETR        
3f892b:              _Fl2808_CompactSector:
003f892b   fe10       ADDB         SP, #16
003f892c   a046       MOVL         *-SP[6], XAR5
003f892d   9643       MOV          *-SP[3], AL
003f892e   a842       MOVL         *-SP[2], XAR4
003f892f   284b       MOV          *-SP[11], #0x03e7
003f8930   03e7
003f8931   c442       MOVL         XAR6, *-SP[2]
003f8932   8f3e       MOVL         XAR4, #0x3e8000
003f8933   8000
003f8934   a8a9       MOVL         ACC, XAR4
003f8935   0fa6       CMPL         ACC, XAR6
003f8936   660d       SB           13, HI
003f8937   c442       MOVL         XAR6, *-SP[2]
003f8938   8f3f       MOVL         XAR4, #0x3f7fff
003f8939   7fff
003f893a   a8a9       MOVL         ACC, XAR4
003f893b   0fa6       CMPL         ACC, XAR6
003f893c   6807       SB           7, LO
003f893d   0642       MOVL         ACC, *-SP[2]
003f893e   ff0f       SUB          ACC, #0x7d << 15
003f893f   007d
003f8940   1e4e       MOVL         *-SP[14], ACC
003f8941   2b4f       MOV          *-SP[15], #0
003f8942   6f03       SB           3, UNC
3f8943:              L1:
003f8943   9a0c       MOVB         AL, #0xc
003f8944   6f39       SB           57, UNC
3f8945:              L2:
003f8945   2848       MOV          *-SP[8], #0x0001
003f8946   0001
3f8947:              L3:
003f8947   284a       MOV          *-SP[10], #0x0017
003f8948   0017
003f8949   2b49       MOV          *-SP[9], #0
003f894a   1b49       CMP          *-SP[9], #2000
003f894b   07d0
003f894c   6621       SB           33, HI
3f894d:              L4:
003f894d   5c4f       MOVZ         AR4, *-SP[15]
003f894e   064e       MOVL         ACC, *-SP[14]
003f894f   767f       LCR          0x3f8853
003f8950   8853
003f8951   9647       MOV          *-SP[7], AL
003f8952   761f       MOVW         DP, #0xfe45
003f8953   fe45
003f8954   0600       MOVL         ACC, @0x0
003f8955   be00       MOVB         XAR6, #0x00
003f8956   0fa6       CMPL         ACC, XAR6
003f8957   ec03       SBF          3, EQ
003f8958   c500       MOVL         XAR7, @0x0
003f8959   3e67       LCR          *XAR7
3f895a:              L5:
003f895a   9247       MOV          AL, *-SP[7]
003f895b   ec08       SBF          8, EQ
003f895c   ff5e       NOT          AL
003f895d   5d4f       MOVZ         AR5, *-SP[15]
003f895e   5ca9       MOVZ         AR4, AL
003f895f   064e       MOVL         ACC, *-SP[14]
003f8960   767f       LCR          0x3f888d
003f8961   888d
003f8962   6f07       SB           7, UNC
3f8963:              L6:
003f8963   2b4a       MOV          *-SP[10], #0
003f8964   064e       MOVL         ACC, *-SP[14]
003f8965   0901       ADDB         ACC, #1
003f8966   1e4e       MOVL         *-SP[14], ACC
003f8967   0a48       INC          *-SP[8]
003f8968   6f05       SB           5, UNC
3f8969:              L7:
003f8969   0a49       INC          *-SP[9]
003f896a   1b49       CMP          *-SP[9], #2000
003f896b   07d0
003f896c   69e1       SB           -31, LOS
3f896d:              L8:
003f896d   924a       MOV          AL, *-SP[10]
003f896e   ec07       SBF          7, EQ
003f896f   1b49       CMP          *-SP[9], #2000
003f8970   07d0
003f8971   6904       SB           4, LOS
003f8972   284b       MOV          *-SP[11], #0x0017
003f8973   0017
003f8974   6f04       SB           4, UNC
3f8975:              L9:
003f8975   9243       MOV          AL, *-SP[3]
003f8976   5448       CMP          AL, *-SP[8]
003f8977   67d0       SB           -48, HIS
3f8978:              L10:
003f8978   924b       MOV          AL, *-SP[11]
003f8979   5217       CMPB         AL, #0x17
003f897a   ec02       SBF          2, EQ
003f897b   2b4b       MOV          *-SP[11], #0
3f897c:              L11:
003f897c   924b       MOV          AL, *-SP[11]
3f897d:              L12:
003f897d   fe90       SUBB         SP, #16
003f897e   0006       LRETR        
3f897f:              _Fl28x_DepRecoverCompactSector:
003f897f   fe0a       ADDB         SP, #10
003f8980   7d44       MOV          *-SP[4], AR5
003f8981   7c43       MOV          *-SP[3], AR4
003f8982   1e42       MOVL         *-SP[2], ACC
003f8983   2849       MOV          *-SP[9], #0x03e7
003f8984   03e7
003f8985   767f       LCR          0x3f875d
003f8986   875d
003f8987   2846       MOV          *-SP[6], #0x0001
003f8988   0001
3f8989:              L1:
003f8989   2848       MOV          *-SP[8], #0x0017
003f898a   0017
003f898b   2b47       MOV          *-SP[7], #0
003f898c   1b47       CMP          *-SP[7], #400
003f898d   0190
003f898e   6621       SB           33, HI
3f898f:              L2:
003f898f   5c44       MOVZ         AR4, *-SP[4]
003f8990   0642       MOVL         ACC, *-SP[2]
003f8991   767f       LCR          0x3f8853
003f8992   8853
003f8993   9645       MOV          *-SP[5], AL
003f8994   761f       MOVW         DP, #0xfe45
003f8995   fe45
003f8996   0600       MOVL         ACC, @0x0
003f8997   be00       MOVB         XAR6, #0x00
003f8998   0fa6       CMPL         ACC, XAR6
003f8999   ec03       SBF          3, EQ
003f899a   c500       MOVL         XAR7, @0x0
003f899b   3e67       LCR          *XAR7
3f899c:              L3:
003f899c   9245       MOV          AL, *-SP[5]
003f899d   ec09       SBF          9, EQ
003f899e   ff5e       NOT          AL
003f899f   5d44       MOVZ         AR5, *-SP[4]
003f89a0   5ca9       MOVZ         AR4, AL
003f89a1   0642       MOVL         ACC, *-SP[2]
003f89a2   767f       LCR          0x3f888d
003f89a3   888d
003f89a4   0a47       INC          *-SP[7]
003f89a5   6f07       SB           7, UNC
3f89a6:              L4:
003f89a6   2b48       MOV          *-SP[8], #0
003f89a7   0642       MOVL         ACC, *-SP[2]
003f89a8   0901       ADDB         ACC, #1
003f89a9   1e42       MOVL         *-SP[2], ACC
003f89aa   0a46       INC          *-SP[6]
003f89ab   6f04       SB           4, UNC
3f89ac:              L5:
003f89ac   1b47       CMP          *-SP[7], #400
003f89ad   0190
003f89ae   69e1       SB           -31, LOS
3f89af:              L6:
003f89af   9248       MOV          AL, *-SP[8]
003f89b0   ec0a       SBF          10, EQ
003f89b1   1b47       CMP          *-SP[7], #400
003f89b2   0190
003f89b3   6907       SB           7, LOS
003f89b4   2849       MOV          *-SP[9], #0x0017
003f89b5   0017
003f89b6   0642       MOVL         ACC, *-SP[2]
003f89b7   0901       ADDB         ACC, #1
003f89b8   1e42       MOVL         *-SP[2], ACC
003f89b9   0a46       INC          *-SP[6]
3f89ba:              L7:
003f89ba   9243       MOV          AL, *-SP[3]
003f89bb   5446       CMP          AL, *-SP[6]
003f89bc   67cd       SB           -51, HIS
003f89bd   767f       LCR          0x3f8750
003f89be   8750
003f89bf   9249       MOV          AL, *-SP[9]
003f89c0   5217       CMPB         AL, #0x17
003f89c1   ec02       SBF          2, EQ
003f89c2   2b49       MOV          *-SP[9], #0
3f89c3:              L8:
003f89c3   9249       MOV          AL, *-SP[9]
003f89c4   fe8a       SUBB         SP, #10
003f89c5   0006       LRETR        
3f89c6:              _c_int00:
003f89c6   28ad       MOV          SP, #0x0200
003f89c7   0200
003f89c8   ff69       SPM          #0
003f89c9   561f       SETC         OBJMODE
003f89ca   5616       CLRC         AMODE
003f89cb   561a       SETC         M0M1MAP
003f89cc   2940       CLRC         PAGE0
003f89cd   761f       MOVW         DP, #0x0
003f89ce   0000
003f89cf   2902       CLRC         OVM
003f89d0   761b       ASP          
003f89d1   7622       EALLOW       
003f89d2   28a9       MOV          AL, #0x8b92
003f89d3   8b92
003f89d4   28a8       MOV          AH, #0x003f
003f89d5   003f
003f89d6   0901       ADDB         ACC, #1
003f89d7   611b       SB           27, EQ
003f89d8   76ff       MOVL         XAR7, #0x3f8b92
003f89d9   8b92
003f89da   2904       CLRC         TC
003f89db   6f0f       SB           15, UNC
003f89dc   9b00       MOVB         AH, #0x0
003f89dd   24a9       PREAD        AL, *XAR7
003f89de   df01       ADDB         XAR7, #1
003f89df   6c04       SB           4, NTC
003f89e0   2904       CLRC         TC
003f89e1   24a8       PREAD        AH, *XAR7
003f89e2   df01       ADDB         XAR7, #1
003f89e3   1ea6       MOVL         XAR6, ACC
003f89e4   f7a1       RPT          AR1
003f89e5   2486    || PREAD        *XAR6++, *XAR7
003f89e6   06a7       MOVL         ACC, XAR7
003f89e7   81a1       ADD          ACC, AR1
003f89e8   0901       ADDB         ACC, #1
003f89e9   1ea7       MOVL         XAR7, ACC
003f89ea   24a9       PREAD        AL, *XAR7
003f89eb   6303       SB           3, GEQ
003f89ec   ff5c       NEG          AL
003f89ed   3b04       SETC         TC
003f89ee   59a9       MOVZ         AR1, AL
003f89ef   df01       ADDB         XAR7, #1
003f89f0   0009       BANZ         -20,AR1--
003f89f1   ffec
003f89f2   761a       EDIS         
003f89f3   28a9       MOV          AL, #0xffff
003f89f4   ffff
003f89f5   28a8       MOV          AH, #0xffff
003f89f6   ffff
003f89f7   0901       ADDB         ACC, #1
003f89f8   610e       SB           14, EQ
003f89f9   76ff       MOVL         XAR7, #0x3fffff
003f89fa   ffff
003f89fb   6f06       SB           6, UNC
003f89fc   df01       ADDB         XAR7, #1
003f89fd   c3bd       MOVL         *SP++, XAR7
003f89fe   1ea7       MOVL         XAR7, ACC
003f89ff   3e67       LCR          *XAR7
003f8a00   c5be       MOVL         XAR7, *--SP
003f8a01   24a9       PREAD        AL, *XAR7
003f8a02   df01       ADDB         XAR7, #1
003f8a03   24a8       PREAD        AH, *XAR7
003f8a04   ff58       TEST         ACC
003f8a05   60f7       SB           -9, NEQ
003f8a06   767f       LCR          0x3f8aff
003f8a07   8aff
003f8a08   767f       LCR          0x3f8b1a
003f8a09   8b1a
3f8a0a:              _Fl28x_ClearLoop:
003f8a0a   fe0c       ADDB         SP, #12
003f8a0b   a846       MOVL         *-SP[6], XAR4
003f8a0c   7d43       MOV          *-SP[3], AR5
003f8a0d   1e42       MOVL         *-SP[2], ACC
003f8a0e   284b       MOV          *-SP[11], #0x03e7
003f8a0f   03e7
003f8a10   2849       MOV          *-SP[9], #0x0001
003f8a11   0001
003f8a12   9243       MOV          AL, *-SP[3]
003f8a13   5449       CMP          AL, *-SP[9]
003f8a14   682d       SB           45, LO
3f8a15:              L1:
003f8a15   2b4a       MOV          *-SP[10], #0
003f8a16   924a       MOV          AL, *-SP[10]
003f8a17   522d       CMPB         AL, #0x2d
003f8a18   671b       SB           27, HIS
3f8a19:              L2:
003f8a19   5c4f       MOVZ         AR4, *-SP[15]
003f8a1a   0642       MOVL         ACC, *-SP[2]
003f8a1b   767f       LCR          0x3f87d4
003f8a1c   87d4
003f8a1d   9647       MOV          *-SP[7], AL
003f8a1e   761f       MOVW         DP, #0xfe45
003f8a1f   fe45
003f8a20   0600       MOVL         ACC, @0x0
003f8a21   be00       MOVB         XAR6, #0x00
003f8a22   0fa6       CMPL         ACC, XAR6
003f8a23   ec03       SBF          3, EQ
003f8a24   c500       MOVL         XAR7, @0x0
003f8a25   3e67       LCR          *XAR7
3f8a26:              L3:
003f8a26   9247       MOV          AL, *-SP[7]
003f8a27   ec0c       SBF          12, EQ
003f8a28   ff5e       NOT          AL
003f8a29   9648       MOV          *-SP[8], AL
003f8a2a   5c48       MOVZ         AR4, *-SP[8]
003f8a2b   5d4f       MOVZ         AR5, *-SP[15]
003f8a2c   0642       MOVL         ACC, *-SP[2]
003f8a2d   767f       LCR          0x3f8811
003f8a2e   8811
003f8a2f   0a4a       INC          *-SP[10]
003f8a30   924a       MOV          AL, *-SP[10]
003f8a31   522d       CMPB         AL, #0x2d
003f8a32   68e7       SB           -25, LO
3f8a33:              L4:
003f8a33   9247       MOV          AL, *-SP[7]
003f8a34   ec06       SBF          6, EQ
003f8a35   924f       MOV          AL, *-SP[15]
003f8a36   ed04       SBF          4, NEQ
003f8a37   284b       MOV          *-SP[11], #0x0015
003f8a38   0015
003f8a39   6f08       SB           8, UNC
3f8a3a:              L5:
003f8a3a   0642       MOVL         ACC, *-SP[2]
003f8a3b   0901       ADDB         ACC, #1
003f8a3c   1e42       MOVL         *-SP[2], ACC
003f8a3d   0a49       INC          *-SP[9]
003f8a3e   9243       MOV          AL, *-SP[3]
003f8a3f   5449       CMP          AL, *-SP[9]
003f8a40   67d5       SB           -43, HIS
3f8a41:              L6:
003f8a41   924b       MOV          AL, *-SP[11]
003f8a42   5215       CMPB         AL, #0x15
003f8a43   ec05       SBF          5, EQ
003f8a44   1ba9       CMP          AL, #999
003f8a45   03e7
003f8a46   ed02       SBF          2, NEQ
003f8a47   2b4b       MOV          *-SP[11], #0
3f8a48:              L7:
003f8a48   924b       MOV          AL, *-SP[11]
003f8a49   fe8c       SUBB         SP, #12
003f8a4a   0006       LRETR        
3f8a4b:              _Fl2808_ClearSector:
003f8a4b   fe0c       ADDB         SP, #12
003f8a4c   a048       MOVL         *-SP[8], XAR5
003f8a4d   9645       MOV          *-SP[5], AL
003f8a4e   a844       MOVL         *-SP[4], XAR4
003f8a4f   c444       MOVL         XAR6, *-SP[4]
003f8a50   8f3e       MOVL         XAR4, #0x3e8000
003f8a51   8000
003f8a52   a8a9       MOVL         ACC, XAR4
003f8a53   0fa6       CMPL         ACC, XAR6
003f8a54   6610       SB           16, HI
003f8a55   8045       MOVZ         AR7, *-SP[5]
003f8a56   0644       MOVL         ACC, *-SP[4]
003f8a57   0da7       ADDU         ACC, AR7
003f8a58   1ea6       MOVL         XAR6, ACC
003f8a59   8f3f       MOVL         XAR4, #0x3f7fff
003f8a5a   7fff
003f8a5b   de81       SUBB         XAR6, #1
003f8a5c   a8a9       MOVL         ACC, XAR4
003f8a5d   0fa6       CMPL         ACC, XAR6
003f8a5e   6806       SB           6, LO
003f8a5f   0644       MOVL         ACC, *-SP[4]
003f8a60   ff0f       SUB          ACC, #0x7d << 15
003f8a61   007d
003f8a62   1e4c       MOVL         *-SP[12], ACC
003f8a63   6f03       SB           3, UNC
3f8a64:              L1:
003f8a64   9a0c       MOVB         AL, #0xc
003f8a65   6f17       SB           23, UNC
3f8a66:              L2:
003f8a66   2841       MOV          *-SP[1], #0x0040
003f8a67   0040
003f8a68   5d45       MOVZ         AR5, *-SP[5]
003f8a69   8a48       MOVL         XAR4, *-SP[8]
003f8a6a   064c       MOVL         ACC, *-SP[12]
003f8a6b   767f       LCR          0x3f8a0a
003f8a6c   8a0a
003f8a6d   2841       MOV          *-SP[1], #0x0080
003f8a6e   0080
003f8a6f   8a48       MOVL         XAR4, *-SP[8]
003f8a70   8f40       MOVL         XAR5, #0x000400
003f8a71   0400
003f8a72   064c       MOVL         ACC, *-SP[12]
003f8a73   767f       LCR          0x3f8a0a
003f8a74   8a0a
003f8a75   2b41       MOV          *-SP[1], #0
003f8a76   5d45       MOVZ         AR5, *-SP[5]
003f8a77   8a48       MOVL         XAR4, *-SP[8]
003f8a78   064c       MOVL         ACC, *-SP[12]
003f8a79   767f       LCR          0x3f8a0a
003f8a7a   8a0a
003f8a7b   9649       MOV          *-SP[9], AL
3f8a7c:              L3:
003f8a7c   fe8c       SUBB         SP, #12
003f8a7d   0006       LRETR        
3f8a7e:              _Flash2808_Verify:
003f8a7e   b2bd       MOVL         *SP++, XAR1
003f8a7f   aabd       MOVL         *SP++, XAR2
003f8a80   a2bd       MOVL         *SP++, XAR3
003f8a81   fe06       ADDB         SP, #6
003f8a82   1e42       MOVL         *-SP[2], ACC
003f8a83   82a5       MOVL         XAR3, XAR5
003f8a84   0650       MOVL         ACC, *-SP[16]
003f8a85   1e44       MOVL         *-SP[4], ACC
003f8a86   8ba4       MOVL         XAR1, XAR4
003f8a87   8a44       MOVL         XAR4, *-SP[4]
003f8a88   767f       LCR          0x3f8adb
003f8a89   8adb
003f8a8a   5200       CMPB         AL, #0x0
003f8a8b   9645       MOV          *-SP[5], AL
003f8a8c   ed1f       SBF          31, NEQ
003f8a8d   0642       MOVL         ACC, *-SP[2]
003f8a8e   ec1d       SBF          29, EQ
003f8a8f   d201       MOVB         XAR2, #0x1
3f8a90:              L1:
003f8a90   761f       MOVW         DP, #0xfe45
003f8a91   fe45
003f8a92   0600       MOVL         ACC, @0x0
003f8a93   be00       MOVB         XAR6, #0x00
003f8a94   0fa6       CMPL         ACC, XAR6
003f8a95   ec03       SBF          3, EQ
003f8a96   1ea7       MOVL         XAR7, ACC
003f8a97   3e67       LCR          *XAR7
3f8a98:              L2:
003f8a98   92c3       MOV          AL, *+XAR3[0]
003f8a99   54c1       CMP          AL, *+XAR1[0]
003f8a9a   ed08       SBF          8, NEQ
003f8a9b   0642       MOVL         ACC, *-SP[2]
003f8a9c   da01       ADDB         XAR2, #1
003f8a9d   d901       ADDB         XAR1, #1
003f8a9e   db01       ADDB         XAR3, #1
003f8a9f   0fa2       CMPL         ACC, XAR2
003f8aa0   67f0       SB           -16, HIS
003f8aa1   6f0a       SB           10, UNC
3f8aa2:              L3:
003f8aa2   8a44       MOVL         XAR4, *-SP[4]
003f8aa3   b2c4       MOVL         *+XAR4[0], XAR1
003f8aa4   8a44       MOVL         XAR4, *-SP[4]
003f8aa5   96d4       MOV          *+XAR4[2], AL
003f8aa6   8a44       MOVL         XAR4, *-SP[4]
003f8aa7   92c1       MOV          AL, *+XAR1[0]
003f8aa8   96dc       MOV          *+XAR4[3], AL
003f8aa9   2845       MOV          *-SP[5], #0x0028
003f8aaa   0028
3f8aab:              L4:
003f8aab   9245       MOV          AL, *-SP[5]
003f8aac   fe86       SUBB         SP, #6
003f8aad   82be       MOVL         XAR3, *--SP
003f8aae   86be       MOVL         XAR2, *--SP
003f8aaf   8bbe       MOVL         XAR1, *--SP
003f8ab0   0006       LRETR        
3f8ab1:              _Flash2808_DepRecover:
003f8ab1   fe06       ADDB         SP, #6
003f8ab2   d400       MOVB         XAR4, #0x0
003f8ab3   767f       LCR          0x3f8adb
003f8ab4   8adb
003f8ab5   9642       MOV          *-SP[2], AL
003f8ab6   5200       CMPB         AL, #0x0
003f8ab7   ed22       SBF          34, NEQ
003f8ab8   2b45       MOV          *-SP[5], #0
003f8ab9   2842       MOV          *-SP[2], #0x0032
003f8aba   0032
003f8abb   2b41       MOV          *-SP[1], #0
003f8abc   9241       MOV          AL, *-SP[1]
003f8abd   5204       CMPB         AL, #0x4
003f8abe   6615       SB           21, HI
3f8abf:              L1:
003f8abf   0e41       MOVU         ACC, *-SP[1]
003f8ac0   8f3f       MOVL         XAR4, #0x3f9160
003f8ac1   9160
003f8ac2   ff31       LSL          ACC, 2
003f8ac3   5601       ADDL         XAR4, ACC
003f8ac4   00a4
003f8ac5   06c4       MOVL         ACC, *+XAR4[0]
003f8ac6   ff0f       SUB          ACC, #0x7d << 15
003f8ac7   007d
003f8ac8   1e44       MOVL         *-SP[4], ACC
003f8ac9   5d45       MOVZ         AR5, *-SP[5]
003f8aca   d480       MOVB         XAR4, #0x80
003f8acb   0644       MOVL         ACC, *-SP[4]
003f8acc   767f       LCR          0x3f897f
003f8acd   897f
003f8ace   7242       ADD          *-SP[2], AL
003f8acf   0a41       INC          *-SP[1]
003f8ad0   9241       MOV          AL, *-SP[1]
003f8ad1   5204       CMPB         AL, #0x4
003f8ad2   69ed       SB           -19, LOS
3f8ad3:              L2:
003f8ad3   9242       MOV          AL, *-SP[2]
003f8ad4   5232       CMPB         AL, #0x32
003f8ad5   ed03       SBF          3, NEQ
003f8ad6   9a00       MOVB         AL, #0x0
003f8ad7   6f02       SB           2, UNC
3f8ad8:              L3:
003f8ad8   9a17       MOVB         AL, #0x17
3f8ad9:              L4:
003f8ad9   fe86       SUBB         SP, #6
003f8ada   0006       LRETR        
3f8adb:              _Fl2808_Init:
003f8adb   b2bd       MOVL         *SP++, XAR1
003f8adc   8ba4       MOVL         XAR1, XAR4
003f8add   767f       LCR          0x3f8b45
003f8ade   8b45
003f8adf   b2a9       MOVL         ACC, XAR1
003f8ae0   ec05       SBF          5, EQ
003f8ae1   0200       MOVB         ACC, #0
003f8ae2   1ec1       MOVL         *+XAR1[0], ACC
003f8ae3   2bd1       MOV          *+XAR1[2], #0
003f8ae4   2bd9       MOV          *+XAR1[3], #0
3f8ae5:              L1:
003f8ae5   8f3f       MOVL         XAR4, #0x3fffb9
003f8ae6   ffb9
003f8ae7   92c4       MOV          AL, *+XAR4[0]
003f8ae8   1ba9       CMP          AL, #-1
003f8ae9   ffff
003f8aea   ec04       SBF          4, EQ
003f8aeb   1ba9       CMP          AL, #-2
003f8aec   fffe
003f8aed   ed0f       SBF          15, NEQ
3f8aee:              L2:
003f8aee   f5a9       MOV          AL, *(0:0x0882)
003f8aef   0882
003f8af0   523c       CMPB         AL, #0x3c
003f8af1   ec03       SBF          3, EQ
003f8af2   9a0d       MOVB         AL, #0xd
003f8af3   6f0a       SB           10, UNC
3f8af4:              L3:
003f8af4   f5a9       MOV          AL, *(0:0x0a88)
003f8af5   0a88
003f8af6   5200       CMPB         AL, #0x0
003f8af7   ec03       SBF          3, EQ
003f8af8   9a00       MOVB         AL, #0x0
003f8af9   6f04       SB           4, UNC
3f8afa:              L4:
003f8afa   9a0a       MOVB         AL, #0xa
003f8afb   6f02       SB           2, UNC
3f8afc:              L5:
003f8afc   9a0e       MOVB         AL, #0xe
3f8afd:              L6:
003f8afd   8bbe       MOVL         XAR1, *--SP
003f8afe   0006       LRETR        
3f8aff:              __args_main:
003f8aff   28ab       MOV          PL, #0xffff
003f8b00   ffff
003f8b01   28aa       MOV          PH, #0xffff
003f8b02   ffff
003f8b03   28a9       MOV          AL, #0xffff
003f8b04   ffff
003f8b05   28a8       MOV          AH, #0xffff
003f8b06   ffff
003f8b07   0fab       CMPL         ACC, P
003f8b08   ed04       SBF          4, NEQ
003f8b09   be00       MOVB         XAR6, #0x00
003f8b0a   d400       MOVB         XAR4, #0x0
003f8b0b   6f09       SB           9, UNC
003f8b0c   8aa9       MOVL         XAR4, ACC
003f8b0d   28a9       MOV          AL, #0xffff
003f8b0e   ffff
003f8b0f   28a8       MOV          AH, #0xffff
003f8b10   ffff
003f8b11   88c4       MOVZ         AR6, *+XAR4[0]
003f8b12   0902       ADDB         ACC, #2
003f8b13   8aa9       MOVL         XAR4, ACC
003f8b14   92a6       MOV          AL, AR6
003f8b15   767f       LCR          0x3f8000
003f8b16   8000
003f8b17   0006       LRETR        
3f8b18:              _abort:
3f8b18:              C$$EXIT:
003f8b18   7700       NOP          
003f8b19   6f00       SB           0, UNC
3f8b1a:              _exit:
003f8b1a   b2bd       MOVL         *SP++, XAR1
003f8b1b   761f       MOVW         DP, #0xfe45
003f8b1c   fe45
003f8b1d   59a9       MOVZ         AR1, AL
003f8b1e   c506       MOVL         XAR7, @0x6
003f8b1f   3e67       LCR          *XAR7
003f8b20   761f       MOVW         DP, #0xfe45
003f8b21   fe45
003f8b22   c50a       MOVL         XAR7, @0xa
003f8b23   06a7       MOVL         ACC, XAR7
003f8b24   ec03       SBF          3, EQ
003f8b25   92a1       MOV          AL, AR1
003f8b26   3e67       LCR          *XAR7
003f8b27   761f       MOVW         DP, #0xfe45
003f8b28   fe45
003f8b29   0608       MOVL         ACC, @0x8
003f8b2a   ec03       SBF          3, EQ
003f8b2b   1ea7       MOVL         XAR7, ACC
003f8b2c   3e67       LCR          *XAR7
003f8b2d   767f       LCR          0x3f8b18
003f8b2e   8b18
003f8b2f   8bbe       MOVL         XAR1, *--SP
003f8b30   0006       LRETR        
3f8b31:              _Flash2808_ToggleTest:
003f8b31   b2bd       MOVL         *SP++, XAR1
003f8b32   aabd       MOVL         *SP++, XAR2
003f8b33   86a9       MOVL         XAR2, ACC
003f8b34   8ba4       MOVL         XAR1, XAR4
003f8b35   f5a9       MOV          AL, *(0:0x7077)
003f8b36   7077
003f8b37   18a9       AND          AL, #0xfffe
003f8b38   fffe
003f8b39   f4a9       MOV          *(0:0x7077), AL
003f8b3a   7077
003f8b3b   767f       LCR          0x3f8b88
003f8b3c   8b88
003f8b3d   767f       LCR          0x3f8b45
003f8b3e   8b45
3f8b3f:              L1:
003f8b3f   aac1       MOVL         *+XAR1[0], XAR2
003f8b40   9a00       MOVB         AL, #0x0
003f8b41   9b32       MOVB         AH, #0x32
003f8b42   767f       LCR          0x3f8b6a
003f8b43   8b6a
003f8b44   6ffb       SB           -5, UNC
3f8b45:              _Fl28x_WatchDogDisable:
003f8b45   7622       EALLOW       
003f8b46   f5a9       MOV          AL, *(0:0x7029)
003f8b47   7029
003f8b48   5068       ORB          AL, #0x68
003f8b49   f4a9       MOV          *(0:0x7029), AL
003f8b4a   7029
003f8b4b   761a       EDIS         
003f8b4c   0006       LRETR        
3f8b4d:              _Fl28x_DisableNMI:
003f8b4d   fe02       ADDB         SP, #2
003f8b4e   f541       MOV          *-SP[1], *(0:0x7077)
003f8b4f   7077
003f8b50   f5a9       MOV          AL, *(0:0x7077)
003f8b51   7077
003f8b52   18a9       AND          AL, #0xfffe
003f8b53   fffe
003f8b54   f4a9       MOV          *(0:0x7077), AL
003f8b55   7077
003f8b56   9241       MOV          AL, *-SP[1]
003f8b57   fe82       SUBB         SP, #2
003f8b58   0006       LRETR        
3f8b59:              _InitGpio:
003f8b59   7622       EALLOW       
003f8b5a   0200       MOVB         ACC, #0
003f8b5b   761f       MOVW         DP, #0x1be
003f8b5c   01be
003f8b5d   1e06       MOVL         @0x6, ACC
003f8b5e   1e08       MOVL         @0x8, ACC
003f8b5f   1e16       MOVL         @0x16, ACC
003f8b60   1e0a       MOVL         @0xa, ACC
003f8b61   1e1a       MOVL         @0x1a, ACC
003f8b62   1e02       MOVL         @0x2, ACC
003f8b63   1e04       MOVL         @0x4, ACC
003f8b64   1e12       MOVL         @0x12, ACC
003f8b65   1e0c       MOVL         @0xc, ACC
003f8b66   1e1c       MOVL         @0x1c, ACC
003f8b67   761a       EDIS         
003f8b68   ff69       SPM          #0
003f8b69   0006       LRETR        
3f8b6a:              _Fl28x_Delay:
3f8b6a:              $ASM$:
003f8b6a   761f       MOVW         DP, #0xfe45
003f8b6b   fe45
003f8b6c   87a9       MOVL         XT, ACC
003f8b6d   5663       QMPYL        ACC, XT, @0x2
003f8b6e   0002
003f8b6f   1934       SUBB         ACC, #52
003f8b70   56c4       BF           6, LT
003f8b71   0006
003f8b72   ff43       SFR          ACC, 4
3f8b73:              _Fl28x_DelayLoop:
003f8b73   1901       SUBB         ACC, #1
003f8b74   56c2       BF           -1, GT
003f8b75   ffff
3f8b76:              _Fl28x_DelayDone:
003f8b76   0006       LRETR        
3f8b77:              __register_unlock:
003f8b77   761f       MOVW         DP, #0xfe45
003f8b78   fe45
003f8b79   a804       MOVL         @0x4, XAR4
003f8b7a   0006       LRETR        
3f8b7b:              __register_lock:
003f8b7b   761f       MOVW         DP, #0xfe45
003f8b7c   fe45
003f8b7d   a806       MOVL         @0x6, XAR4
003f8b7e   0006       LRETR        
3f8b7f:              __nop:
003f8b7f   0006       LRETR        
003f8b80   561f       SETC         OBJMODE
003f8b81   7622       EALLOW       
003f8b82   b9c0       MOVZ         DP, #0x1c0
003f8b83   2829       MOV          @0x29, #0x0068
003f8b84   0068
003f8b85   761a       EDIS         
003f8b86   007f       LB           0x3f89c6
003f8b87   89c6
3f8b88:              _Fl28x_DisableInt:
3f8b88:              $ASM$:
003f8b88   7608       PUSH         ST1
003f8b89   3b30       SETC         INTM|DBGM
003f8b8a   92be       MOV          AL, *--SP
003f8b8b   0006       LRETR        
3f8b8c:              _Fl28x_RestoreInt:
003f8b8c   96bd       MOV          *SP++, AL
003f8b8d   7600       POP          ST1
003f8b8e   0006       LRETR        
3f8b8f:              _Flash2808_APIVersionHex:
003f8b8f   28a9       MOV          AL, #0x0302
003f8b90   0302
003f8b91   0006       LRETR        

	.sect ".cinit"
003f8b92   fffe	.word 0xfffe
003f8b93   9140	.word 0x9140
003f8b94   003f	.word 0x3f
003f8b95   0000	.word 0
003f8b96   0000	.word 0
003f8b97   fffe	.word 0xfffe
003f8b98   9142	.word 0x9142
003f8b99   003f	.word 0x3f
003f8b9a   0000	.word 0
003f8b9b   0000	.word 0
003f8b9c   fffe	.word 0xfffe
003f8b9d   9144	.word 0x9144
003f8b9e   003f	.word 0x3f
003f8b9f   8b7f	.word 0x8b7f
003f8ba0   003f	.word 0x3f
003f8ba1   fffe	.word 0xfffe
003f8ba2   9146	.word 0x9146
003f8ba3   003f	.word 0x3f
003f8ba4   8b7f	.word 0x8b7f
003f8ba5   003f	.word 0x3f
003f8ba6   fffe	.word 0xfffe
003f8ba7   9148	.word 0x9148
003f8ba8   003f	.word 0x3f
003f8ba9   0000	.word 0
003f8baa   0000	.word 0
003f8bab   fffe	.word 0xfffe
003f8bac   914a	.word 0x914a
003f8bad   003f	.word 0x3f
003f8bae   0000	.word 0
003f8baf   0000	.word 0
003f8bb0   0000	.word 0
003f8bb1   0000	.word 0

	.sect ".econst"
003f914c   0008	.word 0x8
003f914d   0004	.word 0x4
003f914e   0002	.word 0x2
003f914f   0001	.word 0x1
003f9150   8000	.word 0x8000
003f9151   003e	.word 0x3e
003f9152   4000	.word 0x4000
003f9153   0000	.word 0
003f9154   c000	.word 0xc000
003f9155   003e	.word 0x3e
003f9156   4000	.word 0x4000
003f9157   0000	.word 0
003f9158   0000	.word 0
003f9159   003f	.word 0x3f
003f915a   4000	.word 0x4000
003f915b   0000	.word 0
003f915c   4000	.word 0x4000
003f915d   003f	.word 0x3f
003f915e   4000	.word 0x4000
003f915f   0000	.word 0
003f9160   8000	.word 0x8000
003f9161   003e	.word 0x3e
003f9162   4000	.word 0x4000
003f9163   0000	.word 0
003f9164   c000	.word 0xc000
003f9165   003e	.word 0x3e
003f9166   4000	.word 0x4000
003f9167   0000	.word 0
003f9168   0000	.word 0
003f9169   003f	.word 0x3f
003f916a   4000	.word 0x4000
003f916b   0000	.word 0
003f916c   4000	.word 0x4000
003f916d   003f	.word 0x3f
003f916e   4000	.word 0x4000
003f916f   0000	.word 0

	.sect ".reset"
00000000   89c6	.word 0x89c6
00000001   003f	.word 0x3f
