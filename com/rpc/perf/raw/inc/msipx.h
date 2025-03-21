//+-------------------------------------------------------------------------
//
//  Microsoft Windows
//
//  Copyright (C) Microsoft Corporation, 1994 - 1999
//
//  File:       msipx.h
//
//--------------------------------------------------------------------------

/*========================================================
	M C S S O C K . H

	This include file is for use with the Windows NT
	WinSock interface.

	This file includes defines and structures for
	IPX and XNS.
=========================================================*/

/**
    This is the structure of the SOCKADDR structure
    for IPX and XNS.
**/

typedef struct _SOCKADDR_NS {
    short sa_family;
    char  sa_netnum[4];
    char  sa_nodenum[6];
    unsigned short sa_socket;
} SOCKADDR_NS, *PSOCKADDR_NS;

/**************************************************************
    	These are the socket options that we support.

	All of these are made with the level set
	to SOL_SOCKET;
***************************************************************/

/** These are for SOCK_DGRAM sockets only **/
/* 0x4000 - 0x407f */

#define SO_SETPTYPE		0x4000	/* Set send packet type	*/
#define SO_GETPTYPE		0x4001	/* Get current send packet type */
#define SO_SETFILTERPTYPE	0x4002	/* Set pkt type to filter recv on */
#define SO_GETFILTERPTYPE	0x4003  /* Get pkt type filtering recv on */
#define SO_STOPFILTERPTYPE	0x4004  /* Stop filtering recv on pkt type*/
#define SO_GETMAXSIZE		0x4005  /* Get max packet size can send   */
#define SO_ENABLE_EXTENDED_ADDRESS  0x4006 /* Put pkt type in address	  */
#define SO_DISABLE_EXTENDED_ADDRESS 0x4007 /* Don't pkt type in address	  */

/** These are for both SOCK_STREAM and SOCK_DGRAM sockets **/
/** 0x4080 - 0x40ff */

#define SO_ENABLE_RECVHDR	0x4080  /* Send pcol hdr on recv as data  */
#define SO_DISABLE_RECVHDR	0x4081  /* Stop sending pcol hdr on recv  */

/** These are for SOCK_STREAM sockets only **/
/* 0x4100 - 0x417f */

#define SO_SETDSTYPE		0x4100  /* Set the datastream type	  */
#define SO_GETDSTYPE		0x4101  /* Get the current datastream type*/

/**************************************************************
    	These are the protocol family values to use in the socket
    	call for SPP and SPX.
***************************************************************/

#define NSPROTO_SPX	1256
#define NSPROTO_SPP	2256

/**
    These are the protocol values for IPX to be used
    in the socket call.  They will assign the default packet
    type.
**/

#define NSPROTO_IPX	    1000	/* Set send pkt type to 0 */
#define NSPROTO_IPX_PT1     1001	/* Set send pkt type to 1 */
#define NSPROTO_IPX_PT2     1002
#define NSPROTO_IPX_PT3     1003
#define NSPROTO_IPX_PT4     1004
#define NSPROTO_IPX_PT5     1005
#define NSPROTO_IPX_PT6     1006
#define NSPROTO_IPX_PT7     1007
#define NSPROTO_IPX_PT8     1008
#define NSPROTO_IPX_PT9     1009
#define NSPROTO_IPX_PT10    1010
#define NSPROTO_IPX_PT11    1011
#define NSPROTO_IPX_PT12    1012
#define NSPROTO_IPX_PT13    1013
#define NSPROTO_IPX_PT14    1014
#define NSPROTO_IPX_PT15    1015
#define NSPROTO_IPX_PT16    1016
#define NSPROTO_IPX_PT17    1017
#define NSPROTO_IPX_PT18    1018
#define NSPROTO_IPX_PT19    1019
#define NSPROTO_IPX_PT20    1020
#define NSPROTO_IPX_PT21    1021
#define NSPROTO_IPX_PT22    1022
#define NSPROTO_IPX_PT23    1023
#define NSPROTO_IPX_PT24    1024
#define NSPROTO_IPX_PT25    1025
#define NSPROTO_IPX_PT26    1026
#define NSPROTO_IPX_PT27    1027
#define NSPROTO_IPX_PT28    1028
#define NSPROTO_IPX_PT29    1029
#define NSPROTO_IPX_PT30    1030
#define NSPROTO_IPX_PT31    1031
#define NSPROTO_IPX_PT32    1032
#define NSPROTO_IPX_PT33    1033
#define NSPROTO_IPX_PT34    1034
#define NSPROTO_IPX_PT35    1035
#define NSPROTO_IPX_PT36    1036
#define NSPROTO_IPX_PT37    1037
#define NSPROTO_IPX_PT38    1038
#define NSPROTO_IPX_PT39    1039
#define NSPROTO_IPX_PT40    1040
#define NSPROTO_IPX_PT41    1041
#define NSPROTO_IPX_PT42    1042
#define NSPROTO_IPX_PT43    1043
#define NSPROTO_IPX_PT44    1044
#define NSPROTO_IPX_PT45    1045
#define NSPROTO_IPX_PT46    1046
#define NSPROTO_IPX_PT47    1047
#define NSPROTO_IPX_PT48    1048
#define NSPROTO_IPX_PT49    1049
#define NSPROTO_IPX_PT50    1050
#define NSPROTO_IPX_PT51    1051
#define NSPROTO_IPX_PT52    1052
#define NSPROTO_IPX_PT53    1053
#define NSPROTO_IPX_PT54    1054
#define NSPROTO_IPX_PT55    1055
#define NSPROTO_IPX_PT56    1056
#define NSPROTO_IPX_PT57    1057
#define NSPROTO_IPX_PT58    1058
#define NSPROTO_IPX_PT59    1059
#define NSPROTO_IPX_PT60    1060
#define NSPROTO_IPX_PT61    1061
#define NSPROTO_IPX_PT62    1062
#define NSPROTO_IPX_PT63    1063
#define NSPROTO_IPX_PT64    1064
#define NSPROTO_IPX_PT65    1065
#define NSPROTO_IPX_PT66    1066
#define NSPROTO_IPX_PT67    1067
#define NSPROTO_IPX_PT68    1068
#define NSPROTO_IPX_PT69    1069
#define NSPROTO_IPX_PT70    1070
#define NSPROTO_IPX_PT71    1071
#define NSPROTO_IPX_PT72    1072
#define NSPROTO_IPX_PT73    1073
#define NSPROTO_IPX_PT74    1074
#define NSPROTO_IPX_PT75    1075
#define NSPROTO_IPX_PT76    1076
#define NSPROTO_IPX_PT77    1077
#define NSPROTO_IPX_PT78    1078
#define NSPROTO_IPX_PT79    1079
#define NSPROTO_IPX_PT80    1080
#define NSPROTO_IPX_PT81    1081
#define NSPROTO_IPX_PT82    1082
#define NSPROTO_IPX_PT83    1083
#define NSPROTO_IPX_PT84    1084
#define NSPROTO_IPX_PT85    1085
#define NSPROTO_IPX_PT86    1086
#define NSPROTO_IPX_PT87    1087
#define NSPROTO_IPX_PT88    1088
#define NSPROTO_IPX_PT89    1089
#define NSPROTO_IPX_PT90    1090
#define NSPROTO_IPX_PT91    1091
#define NSPROTO_IPX_PT92    1092
#define NSPROTO_IPX_PT93    1093
#define NSPROTO_IPX_PT94    1094
#define NSPROTO_IPX_PT95    1095
#define NSPROTO_IPX_PT96    1096
#define NSPROTO_IPX_PT97    1097
#define NSPROTO_IPX_PT98    1098
#define NSPROTO_IPX_PT99    1099
#define NSPROTO_IPX_PT100   1100
#define NSPROTO_IPX_PT101   1101
#define NSPROTO_IPX_PT102   1102
#define NSPROTO_IPX_PT103   1103
#define NSPROTO_IPX_PT104   1104
#define NSPROTO_IPX_PT105   1105
#define NSPROTO_IPX_PT106   1106
#define NSPROTO_IPX_PT107   1107
#define NSPROTO_IPX_PT108   1108
#define NSPROTO_IPX_PT109   1109
#define NSPROTO_IPX_PT110   1110
#define NSPROTO_IPX_PT111   1111
#define NSPROTO_IPX_PT112   1112
#define NSPROTO_IPX_PT113   1113
#define NSPROTO_IPX_PT114   1114
#define NSPROTO_IPX_PT115   1115
#define NSPROTO_IPX_PT116   1116
#define NSPROTO_IPX_PT117   1117
#define NSPROTO_IPX_PT118   1118
#define NSPROTO_IPX_PT119   1119
#define NSPROTO_IPX_PT120   1120
#define NSPROTO_IPX_PT121   1121
#define NSPROTO_IPX_PT122   1122
#define NSPROTO_IPX_PT123   1123
#define NSPROTO_IPX_PT124   1124
#define NSPROTO_IPX_PT125   1125
#define NSPROTO_IPX_PT126   1126
#define NSPROTO_IPX_PT127   1127
#define NSPROTO_IPX_PT128   1128
#define NSPROTO_IPX_PT129   1129
#define NSPROTO_IPX_PT130   1130
#define NSPROTO_IPX_PT131   1131
#define NSPROTO_IPX_PT132   1132
#define NSPROTO_IPX_PT133   1133
#define NSPROTO_IPX_PT134   1134
#define NSPROTO_IPX_PT135   1135
#define NSPROTO_IPX_PT136   1136
#define NSPROTO_IPX_PT137   1137
#define NSPROTO_IPX_PT138   1138
#define NSPROTO_IPX_PT139   1139
#define NSPROTO_IPX_PT140   1140
#define NSPROTO_IPX_PT141   1141
#define NSPROTO_IPX_PT142   1142
#define NSPROTO_IPX_PT143   1143
#define NSPROTO_IPX_PT144   1144
#define NSPROTO_IPX_PT145   1145
#define NSPROTO_IPX_PT146   1146
#define NSPROTO_IPX_PT147   1147
#define NSPROTO_IPX_PT148   1148
#define NSPROTO_IPX_PT149   1149
#define NSPROTO_IPX_PT150   1150
#define NSPROTO_IPX_PT151   1151
#define NSPROTO_IPX_PT152   1152
#define NSPROTO_IPX_PT153   1153
#define NSPROTO_IPX_PT154   1154
#define NSPROTO_IPX_PT155   1155
#define NSPROTO_IPX_PT156   1156
#define NSPROTO_IPX_PT157   1157
#define NSPROTO_IPX_PT158   1158
#define NSPROTO_IPX_PT159   1159
#define NSPROTO_IPX_PT160   1160
#define NSPROTO_IPX_PT161   1161
#define NSPROTO_IPX_PT162   1162
#define NSPROTO_IPX_PT163   1163
#define NSPROTO_IPX_PT164   1164
#define NSPROTO_IPX_PT165   1165
#define NSPROTO_IPX_PT166   1166
#define NSPROTO_IPX_PT167   1167
#define NSPROTO_IPX_PT168   1168
#define NSPROTO_IPX_PT169   1169
#define NSPROTO_IPX_PT170   1170
#define NSPROTO_IPX_PT171   1171
#define NSPROTO_IPX_PT172   1172
#define NSPROTO_IPX_PT173   1173
#define NSPROTO_IPX_PT174   1174
#define NSPROTO_IPX_PT175   1175
#define NSPROTO_IPX_PT176   1176
#define NSPROTO_IPX_PT177   1177
#define NSPROTO_IPX_PT178   1178
#define NSPROTO_IPX_PT179   1179
#define NSPROTO_IPX_PT180   1180
#define NSPROTO_IPX_PT181   1181
#define NSPROTO_IPX_PT182   1182
#define NSPROTO_IPX_PT183   1183
#define NSPROTO_IPX_PT184   1184
#define NSPROTO_IPX_PT185   1185
#define NSPROTO_IPX_PT186   1186
#define NSPROTO_IPX_PT187   1187
#define NSPROTO_IPX_PT188   1188
#define NSPROTO_IPX_PT189   1189
#define NSPROTO_IPX_PT190   1190
#define NSPROTO_IPX_PT191   1191
#define NSPROTO_IPX_PT192   1192
#define NSPROTO_IPX_PT193   1193
#define NSPROTO_IPX_PT194   1194
#define NSPROTO_IPX_PT195   1195
#define NSPROTO_IPX_PT196   1196
#define NSPROTO_IPX_PT197   1197
#define NSPROTO_IPX_PT198   1198
#define NSPROTO_IPX_PT199   1199
#define NSPROTO_IPX_PT200   1200
#define NSPROTO_IPX_PT201   1201
#define NSPROTO_IPX_PT202   1202
#define NSPROTO_IPX_PT203   1203
#define NSPROTO_IPX_PT204   1204
#define NSPROTO_IPX_PT205   1205
#define NSPROTO_IPX_PT206   1206
#define NSPROTO_IPX_PT207   1207
#define NSPROTO_IPX_PT208   1208
#define NSPROTO_IPX_PT209   1209
#define NSPROTO_IPX_PT210   1210
#define NSPROTO_IPX_PT211   1211
#define NSPROTO_IPX_PT212   1212
#define NSPROTO_IPX_PT213   1213
#define NSPROTO_IPX_PT214   1214
#define NSPROTO_IPX_PT215   1215
#define NSPROTO_IPX_PT216   1216
#define NSPROTO_IPX_PT217   1217
#define NSPROTO_IPX_PT218   1218
#define NSPROTO_IPX_PT219   1219
#define NSPROTO_IPX_PT220   1220
#define NSPROTO_IPX_PT221   1221
#define NSPROTO_IPX_PT222   1222
#define NSPROTO_IPX_PT223   1223
#define NSPROTO_IPX_PT224   1224
#define NSPROTO_IPX_PT225   1225
#define NSPROTO_IPX_PT226   1226
#define NSPROTO_IPX_PT227   1227
#define NSPROTO_IPX_PT228   1228
#define NSPROTO_IPX_PT229   1229
#define NSPROTO_IPX_PT230   1230
#define NSPROTO_IPX_PT231   1231
#define NSPROTO_IPX_PT232   1232
#define NSPROTO_IPX_PT233   1233
#define NSPROTO_IPX_PT234   1234
#define NSPROTO_IPX_PT235   1235
#define NSPROTO_IPX_PT236   1236
#define NSPROTO_IPX_PT237   1237
#define NSPROTO_IPX_PT238   1238
#define NSPROTO_IPX_PT239   1239
#define NSPROTO_IPX_PT240   1240
#define NSPROTO_IPX_PT241   1241
#define NSPROTO_IPX_PT242   1242
#define NSPROTO_IPX_PT243   1243
#define NSPROTO_IPX_PT244   1244
#define NSPROTO_IPX_PT245   1245
#define NSPROTO_IPX_PT246   1246
#define NSPROTO_IPX_PT247   1247
#define NSPROTO_IPX_PT248   1248
#define NSPROTO_IPX_PT249   1249
#define NSPROTO_IPX_PT250   1250
#define NSPROTO_IPX_PT251   1251
#define NSPROTO_IPX_PT252   1252
#define NSPROTO_IPX_PT253   1253
#define NSPROTO_IPX_PT254   1254
#define NSPROTO_IPX_PT255   1255

/**
    These are the protocol values for IDP to be used
    in the socket call.  They will assign the default packet
    type.
**/

#define NSPROTO_IDP	    2000	/* Set send pkt type to 0 */
#define NSPROTO_IDP_PT1     2001	/* Set send pkt type to 1 */
#define NSPROTO_IDP_PT2     2002
#define NSPROTO_IDP_PT3     2003
#define NSPROTO_IDP_PT4     2004
#define NSPROTO_IDP_PT5     2005
#define NSPROTO_IDP_PT6     2006
#define NSPROTO_IDP_PT7     2007
#define NSPROTO_IDP_PT8     2008
#define NSPROTO_IDP_PT9     2009
#define NSPROTO_IDP_PT10    2010
#define NSPROTO_IDP_PT11    2011
#define NSPROTO_IDP_PT12    2012
#define NSPROTO_IDP_PT13    2013
#define NSPROTO_IDP_PT14    2014
#define NSPROTO_IDP_PT15    2015
#define NSPROTO_IDP_PT16    2016
#define NSPROTO_IDP_PT17    2017
#define NSPROTO_IDP_PT18    2018
#define NSPROTO_IDP_PT19    2019
#define NSPROTO_IDP_PT20    2020
#define NSPROTO_IDP_PT21    2021
#define NSPROTO_IDP_PT22    2022
#define NSPROTO_IDP_PT23    2023
#define NSPROTO_IDP_PT24    2024
#define NSPROTO_IDP_PT25    2025
#define NSPROTO_IDP_PT26    2026
#define NSPROTO_IDP_PT27    2027
#define NSPROTO_IDP_PT28    2028
#define NSPROTO_IDP_PT29    2029
#define NSPROTO_IDP_PT30    2030
#define NSPROTO_IDP_PT31    2031
#define NSPROTO_IDP_PT32    2032
#define NSPROTO_IDP_PT33    2033
#define NSPROTO_IDP_PT34    2034
#define NSPROTO_IDP_PT35    2035
#define NSPROTO_IDP_PT36    2036
#define NSPROTO_IDP_PT37    2037
#define NSPROTO_IDP_PT38    2038
#define NSPROTO_IDP_PT39    2039
#define NSPROTO_IDP_PT40    2040
#define NSPROTO_IDP_PT41    2041
#define NSPROTO_IDP_PT42    2042
#define NSPROTO_IDP_PT43    2043
#define NSPROTO_IDP_PT44    2044
#define NSPROTO_IDP_PT45    2045
#define NSPROTO_IDP_PT46    2046
#define NSPROTO_IDP_PT47    2047
#define NSPROTO_IDP_PT48    2048
#define NSPROTO_IDP_PT49    2049
#define NSPROTO_IDP_PT50    2050
#define NSPROTO_IDP_PT51    2051
#define NSPROTO_IDP_PT52    2052
#define NSPROTO_IDP_PT53    2053
#define NSPROTO_IDP_PT54    2054
#define NSPROTO_IDP_PT55    2055
#define NSPROTO_IDP_PT56    2056
#define NSPROTO_IDP_PT57    2057
#define NSPROTO_IDP_PT58    2058
#define NSPROTO_IDP_PT59    2059
#define NSPROTO_IDP_PT60    2060
#define NSPROTO_IDP_PT61    2061
#define NSPROTO_IDP_PT62    2062
#define NSPROTO_IDP_PT63    2063
#define NSPROTO_IDP_PT64    2064
#define NSPROTO_IDP_PT65    2065
#define NSPROTO_IDP_PT66    2066
#define NSPROTO_IDP_PT67    2067
#define NSPROTO_IDP_PT68    2068
#define NSPROTO_IDP_PT69    2069
#define NSPROTO_IDP_PT70    2070
#define NSPROTO_IDP_PT71    2071
#define NSPROTO_IDP_PT72    2072
#define NSPROTO_IDP_PT73    2073
#define NSPROTO_IDP_PT74    2074
#define NSPROTO_IDP_PT75    2075
#define NSPROTO_IDP_PT76    2076
#define NSPROTO_IDP_PT77    2077
#define NSPROTO_IDP_PT78    2078
#define NSPROTO_IDP_PT79    2079
#define NSPROTO_IDP_PT80    2080
#define NSPROTO_IDP_PT81    2081
#define NSPROTO_IDP_PT82    2082
#define NSPROTO_IDP_PT83    2083
#define NSPROTO_IDP_PT84    2084
#define NSPROTO_IDP_PT85    2085
#define NSPROTO_IDP_PT86    2086
#define NSPROTO_IDP_PT87    2087
#define NSPROTO_IDP_PT88    2088
#define NSPROTO_IDP_PT89    2089
#define NSPROTO_IDP_PT90    2090
#define NSPROTO_IDP_PT91    2091
#define NSPROTO_IDP_PT92    2092
#define NSPROTO_IDP_PT93    2093
#define NSPROTO_IDP_PT94    2094
#define NSPROTO_IDP_PT95    2095
#define NSPROTO_IDP_PT96    2096
#define NSPROTO_IDP_PT97    2097
#define NSPROTO_IDP_PT98    2098
#define NSPROTO_IDP_PT99    2099
#define NSPROTO_IDP_PT100   2100
#define NSPROTO_IDP_PT101   2101
#define NSPROTO_IDP_PT102   2102
#define NSPROTO_IDP_PT103   2103
#define NSPROTO_IDP_PT104   2104
#define NSPROTO_IDP_PT105   2105
#define NSPROTO_IDP_PT106   2106
#define NSPROTO_IDP_PT107   2107
#define NSPROTO_IDP_PT108   2108
#define NSPROTO_IDP_PT109   2109
#define NSPROTO_IDP_PT110   2110
#define NSPROTO_IDP_PT111   2111
#define NSPROTO_IDP_PT112   2112
#define NSPROTO_IDP_PT113   2113
#define NSPROTO_IDP_PT114   2114
#define NSPROTO_IDP_PT115   2115
#define NSPROTO_IDP_PT116   2116
#define NSPROTO_IDP_PT117   2117
#define NSPROTO_IDP_PT118   2118
#define NSPROTO_IDP_PT119   2119
#define NSPROTO_IDP_PT120   2120
#define NSPROTO_IDP_PT121   2121
#define NSPROTO_IDP_PT122   2122
#define NSPROTO_IDP_PT123   2123
#define NSPROTO_IDP_PT124   2124
#define NSPROTO_IDP_PT125   2125
#define NSPROTO_IDP_PT126   2126
#define NSPROTO_IDP_PT127   2127
#define NSPROTO_IDP_PT128   2128
#define NSPROTO_IDP_PT129   2129
#define NSPROTO_IDP_PT130   2130
#define NSPROTO_IDP_PT131   2131
#define NSPROTO_IDP_PT132   2132
#define NSPROTO_IDP_PT133   2133
#define NSPROTO_IDP_PT134   2134
#define NSPROTO_IDP_PT135   2135
#define NSPROTO_IDP_PT136   2136
#define NSPROTO_IDP_PT137   2137
#define NSPROTO_IDP_PT138   2138
#define NSPROTO_IDP_PT139   2139
#define NSPROTO_IDP_PT140   2140
#define NSPROTO_IDP_PT141   2141
#define NSPROTO_IDP_PT142   2142
#define NSPROTO_IDP_PT143   2143
#define NSPROTO_IDP_PT144   2144
#define NSPROTO_IDP_PT145   2145
#define NSPROTO_IDP_PT146   2146
#define NSPROTO_IDP_PT147   2147
#define NSPROTO_IDP_PT148   2148
#define NSPROTO_IDP_PT149   2149
#define NSPROTO_IDP_PT150   2150
#define NSPROTO_IDP_PT151   2151
#define NSPROTO_IDP_PT152   2152
#define NSPROTO_IDP_PT153   2153
#define NSPROTO_IDP_PT154   2154
#define NSPROTO_IDP_PT155   2155
#define NSPROTO_IDP_PT156   2156
#define NSPROTO_IDP_PT157   2157
#define NSPROTO_IDP_PT158   2158
#define NSPROTO_IDP_PT159   2159
#define NSPROTO_IDP_PT160   2160
#define NSPROTO_IDP_PT161   2161
#define NSPROTO_IDP_PT162   2162
#define NSPROTO_IDP_PT163   2163
#define NSPROTO_IDP_PT164   2164
#define NSPROTO_IDP_PT165   2165
#define NSPROTO_IDP_PT166   2166
#define NSPROTO_IDP_PT167   2167
#define NSPROTO_IDP_PT168   2168
#define NSPROTO_IDP_PT169   2169
#define NSPROTO_IDP_PT170   2170
#define NSPROTO_IDP_PT171   2171
#define NSPROTO_IDP_PT172   2172
#define NSPROTO_IDP_PT173   2173
#define NSPROTO_IDP_PT174   2174
#define NSPROTO_IDP_PT175   2175
#define NSPROTO_IDP_PT176   2176
#define NSPROTO_IDP_PT177   2177
#define NSPROTO_IDP_PT178   2178
#define NSPROTO_IDP_PT179   2179
#define NSPROTO_IDP_PT180   2180
#define NSPROTO_IDP_PT181   2181
#define NSPROTO_IDP_PT182   2182
#define NSPROTO_IDP_PT183   2183
#define NSPROTO_IDP_PT184   2184
#define NSPROTO_IDP_PT185   2185
#define NSPROTO_IDP_PT186   2186
#define NSPROTO_IDP_PT187   2187
#define NSPROTO_IDP_PT188   2188
#define NSPROTO_IDP_PT189   2189
#define NSPROTO_IDP_PT190   2190
#define NSPROTO_IDP_PT191   2191
#define NSPROTO_IDP_PT192   2192
#define NSPROTO_IDP_PT193   2193
#define NSPROTO_IDP_PT194   2194
#define NSPROTO_IDP_PT195   2195
#define NSPROTO_IDP_PT196   2196
#define NSPROTO_IDP_PT197   2197
#define NSPROTO_IDP_PT198   2198
#define NSPROTO_IDP_PT199   2199
#define NSPROTO_IDP_PT200   2200
#define NSPROTO_IDP_PT201   2201
#define NSPROTO_IDP_PT202   2202
#define NSPROTO_IDP_PT203   2203
#define NSPROTO_IDP_PT204   2204
#define NSPROTO_IDP_PT205   2205
#define NSPROTO_IDP_PT206   2206
#define NSPROTO_IDP_PT207   2207
#define NSPROTO_IDP_PT208   2208
#define NSPROTO_IDP_PT209   2209
#define NSPROTO_IDP_PT210   2210
#define NSPROTO_IDP_PT211   2211
#define NSPROTO_IDP_PT212   2212
#define NSPROTO_IDP_PT213   2213
#define NSPROTO_IDP_PT214   2214
#define NSPROTO_IDP_PT215   2215
#define NSPROTO_IDP_PT216   2216
#define NSPROTO_IDP_PT217   2217
#define NSPROTO_IDP_PT218   2218
#define NSPROTO_IDP_PT219   2219
#define NSPROTO_IDP_PT220   2220
#define NSPROTO_IDP_PT221   2221
#define NSPROTO_IDP_PT222   2222
#define NSPROTO_IDP_PT223   2223
#define NSPROTO_IDP_PT224   2224
#define NSPROTO_IDP_PT225   2225
#define NSPROTO_IDP_PT226   2226
#define NSPROTO_IDP_PT227   2227
#define NSPROTO_IDP_PT228   2228
#define NSPROTO_IDP_PT229   2229
#define NSPROTO_IDP_PT230   2230
#define NSPROTO_IDP_PT231   2231
#define NSPROTO_IDP_PT232   2232
#define NSPROTO_IDP_PT233   2233
#define NSPROTO_IDP_PT234   2234
#define NSPROTO_IDP_PT235   2235
#define NSPROTO_IDP_PT236   2236
#define NSPROTO_IDP_PT237   2237
#define NSPROTO_IDP_PT238   2238
#define NSPROTO_IDP_PT239   2239
#define NSPROTO_IDP_PT240   2240
#define NSPROTO_IDP_PT241   2241
#define NSPROTO_IDP_PT242   2242
#define NSPROTO_IDP_PT243   2243
#define NSPROTO_IDP_PT244   2244
#define NSPROTO_IDP_PT245   2245
#define NSPROTO_IDP_PT246   2246
#define NSPROTO_IDP_PT247   2247
#define NSPROTO_IDP_PT248   2248
#define NSPROTO_IDP_PT249   2249
#define NSPROTO_IDP_PT250   2250
#define NSPROTO_IDP_PT251   2251
#define NSPROTO_IDP_PT252   2252
#define NSPROTO_IDP_PT253   2253
#define NSPROTO_IDP_PT254   2254
#define NSPROTO_IDP_PT255   2255
