pragma solidity 		^0.4.21	;						
										
	contract	FGRE_Portfolio_III_883				{				
										
		mapping (address =&gt; uint256) public balanceOf;								
										
		string	public		name =	&quot;	FGRE_Portfolio_III_883		&quot;	;
		string	public		symbol =	&quot;	FGRE883III		&quot;	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		26619797430723400000000000000					;	
										
		event Transfer(address indexed from, address indexed to, uint256 value);								
										
		function SimpleERC20Token() public {								
			balanceOf[msg.sender] = totalSupply;							
			emit Transfer(address(0), msg.sender, totalSupply);							
		}								
										
		function transfer(address to, uint256 value) public returns (bool success) {								
			require(balanceOf[msg.sender] &gt;= value);							
										
			balanceOf[msg.sender] -= value;  // deduct from sender&#39;s balance							
			balanceOf[to] += value;          // add to recipient&#39;s balance							
			emit Transfer(msg.sender, to, value);							
			return true;							
		}								
										
		event Approval(address indexed owner, address indexed spender, uint256 value);								
										
		mapping(address =&gt; mapping(address =&gt; uint256)) public allowance;								
										
		function approve(address spender, uint256 value)								
			public							
			returns (bool success)							
		{								
			allowance[msg.sender][spender] = value;							
			emit Approval(msg.sender, spender, value);							
			return true;							
		}								
										
		function transferFrom(address from, address to, uint256 value)								
			public							
			returns (bool success)							
		{								
			require(value &lt;= balanceOf[from]);							
			require(value &lt;= allowance[from][msg.sender]);							
										
			balanceOf[from] -= value;							
			balanceOf[to] += value;							
			allowance[from][msg.sender] -= value;							
			emit Transfer(from, to, value);							
			return true;							
		}								
//	}									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	// Programme d&#39;&#233;mission - Lignes 1 &#224; 10									
	//									
	//									
	//									
	//									
	//     [ Nom du portefeuille ; Num&#233;ro de la ligne ; Nom de la ligne ; Ech&#233;ance ]									
	//         [ Adresse export&#233;e ]									
	//         [ Unit&#233; ; Limite basse ; Limite haute ]									
	//         [ Hex ]									
	//									
	//									
	//									
	//     &lt; FGRE_Portfolio_III_metadata_line_1_____Caisse_Centrale_de_Reassurance_20580515 &gt;									
	//        &lt; VMuKyB9YtJi0Q9l1ME3eR2YuzummH9UmNvqq7p9Zwm3puu9Ia562JTGUD7zMQ8AA &gt;									
	//        &lt; 1E-018 limites [ 1E-018 ; 1798005141,81932 ] &gt;									
	//        &lt; 0x000000000000000000000000000000000000000000000000000000000AB789C2 &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_2_____CCR_FGRE_Fonds_de_Garantie_des_Risques_li&#233;s_a_l_Epandage_des_Boues_d_Epuration_Urbaines_et_Industrielles_20580515 &gt;									
	//        &lt; m0XE20rXgPDVF8039lWgGKnb9Kl7vD1asuK5bS8T2fWb584P6EyKzl0QNqh9r9lD &gt;									
	//        &lt; 1E-018 limites [ 1798005141,81932 ; 2064548711,07528 ] &gt;									
	//        &lt; 0x00000000000000000000000000000000000000000000000000AB789C2C4E4057 &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_3_____CCR_FGRE_IDX_ZONE_57410_57410_57412_10_01_20580515 &gt;									
	//        &lt; J6XxmZ3LF8biukPV0mDV6AD6Y9t59VlI489m92t6x6ldf50x5YFCQTVUyiLB98eB &gt;									
	//        &lt; 1E-018 limites [ 2064548711,07528 ; 2240313178,26478 ] &gt;									
	//        &lt; 0x00000000000000000000000000000000000000000000000000C4E4057D5A7256 &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_4_____CCR_FGRE_IDX_ZONE_57410_57410_57412_10_02_20580515 &gt;									
	//        &lt; WAkfxtQXI1R6TR37lwl8A9WXVYb7SJ0hYTVz92YohZacQcwmy73y23MN6BW1K3fK &gt;									
	//        &lt; 1E-018 limites [ 2240313178,26478 ; 4002480171,36732 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000000D5A725617DB4CD1 &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_5_____CCR_FGRE_IDX_ZONE_57410_57410_57412_10_03_20580515 &gt;									
	//        &lt; V9m1C22jY1lntBTIMQxrQKv9bLBvF1ZoGQ9Je5Bv3I4Lsoe5XB6M9Kj0wn88M025 &gt;									
	//        &lt; 1E-018 limites [ 4002480171,36732 ; 4082875147,90688 ] &gt;									
	//        &lt; 0x00000000000000000000000000000000000000000000000017DB4CD11855F91B &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_6_____CCR_FGRE_IDX_ZONE_57410_57410_57412_10_04_20580515 &gt;									
	//        &lt; wr475Vj0LlYY2ZxK6Btw4j978VgHrWrEC13g790vy6qBFj8jR5BA1wks99k1k8hV &gt;									
	//        &lt; 1E-018 limites [ 4082875147,90688 ; 4354066048,28292 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000001855F91B19F3C70D &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_7_____CCR_FGRE_IDX_ZONE_57410_57410_57412_10_05_20580515 &gt;									
	//        &lt; Ha89YKhucEB55qOnG4s20Cd7rQA0VtZgx8VSRHP5w2FB7WzZMLU1zW5hvo9V31S3 &gt;									
	//        &lt; 1E-018 limites [ 4354066048,28292 ; 4533966252,41138 ] &gt;									
	//        &lt; 0x00000000000000000000000000000000000000000000000019F3C70D1B064891 &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_8_____CCR_FGRE_IDX_ZONE_57410_57410_57412_10_06_20580515 &gt;									
	//        &lt; vPRIZEA0GQVwWhlSHyEJIBKClLr21D99YA607ZtKAhT02geM26H946uBc7CKcT60 &gt;									
	//        &lt; 1E-018 limites [ 4533966252,41138 ; 4827440063,51674 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000001B0648911CC616C6 &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_9_____CCR_FGRE_IDX_ZONE_57410_57410_57412_10_07_20580515 &gt;									
	//        &lt; H6e4KpJeQbkgg5Y8L297903S34yUnVJ9VD9p19750ocwPn1LyRF464CY3dx2SGd6 &gt;									
	//        &lt; 1E-018 limites [ 4827440063,51674 ; 4951027942,36309 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000001CC616C61D82AB4A &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_10_____CCR_FGRE_IDX_ZONE_57410_57410_57412_10_08_20580515 &gt;									
	//        &lt; 1U34yk2HwJb1f16xyd2z6sgt5E1y5XYlRJUKwfWKxN61g5aLAqHuB93mkS93NfTd &gt;									
	//        &lt; 1E-018 limites [ 4951027942,36309 ; 5420463977,60449 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000001D82AB4A204EF8BE &gt;									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	// Programme d&#39;&#233;mission - Lignes 11 &#224; 20									
	//									
	//									
	//									
	//									
	//     [ Nom du portefeuille ; Num&#233;ro de la ligne ; Nom de la ligne ; Ech&#233;ance ]									
	//         [ Adresse export&#233;e ]									
	//         [ Unit&#233; ; Limite basse ; Limite haute ]									
	//         [ Hex ]									
	//									
	//									
	//									
	//     &lt; FGRE_Portfolio_III_metadata_line_11_____CCR_FGRE_IDX_ZONE_57410_57410_57412_10_09_20580515 &gt;									
	//        &lt; 5Ij16Xs9SDhNdEj6H6nAZWtq5OqyChd3p6KfXC42L44m290S6032QJ1633iTxAAX &gt;									
	//        &lt; 1E-018 limites [ 5420463977,60449 ; 5668663249,8329 ] &gt;									
	//        &lt; 0x000000000000000000000000000000000000000000000000204EF8BE21C9B195 &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_12_____CCR_FGRE_IDX_ZONE_57410_57410_57412_10_10_20580515 &gt;									
	//        &lt; 6s4Lc4aW1z0w29w2MPF9WY065M0WG6bIT583q53301A9C5EYm5Vlj4w9V690brq3 &gt;									
	//        &lt; 1E-018 limites [ 5668663249,8329 ; 6827545815,83845 ] &gt;									
	//        &lt; 0x00000000000000000000000000000000000000000000000021C9B19528B20216 &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_13_____CCR_FGRE_IDX_ZONE_57410_57410_57412_10_11_20580515 &gt;									
	//        &lt; 0Xf5IT0I2h53013423Zn9bt8Y108XHj450xdZCch2NWM27SP55xhBu0AZH8vBqwN &gt;									
	//        &lt; 1E-018 limites [ 6827545815,83845 ; 7344128542,76922 ] &gt;									
	//        &lt; 0x00000000000000000000000000000000000000000000000028B202162BC64036 &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_14_____CCR_FGRE_IDX_ZONE_57410_57410_57412_10_12_20580515 &gt;									
	//        &lt; KfcF5QBUqCDY065TNNuuS7092Ya1iC8lHDq4MR8Vidw1gSQ5I1v2m87cWmQhjXIc &gt;									
	//        &lt; 1E-018 limites [ 7344128542,76922 ; 7918577398,25259 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000002BC640362F32CA4C &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_15_____CCR_FGRE_IDX_ZONE_57410_57410_57412_10_13_20580515 &gt;									
	//        &lt; KDWZ8qFGgSJ8A9Op13W13FspTRN9R3Cwh1Ft2NmVS50D7K9CkWtV5K4jFUlUNS5D &gt;									
	//        &lt; 1E-018 limites [ 7918577398,25259 ; 8019770428,18954 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000002F32CA4C2FCD32D3 &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_16_____CCR_FGRE_IDX_ZONE_57410_57410_57412_10_14_20580515 &gt;									
	//        &lt; Ua394KR92F59H93RZaiwI95yF19tFJ849Cth0283nlTPgu272nm7Qg75Xi96CinQ &gt;									
	//        &lt; 1E-018 limites [ 8019770428,18954 ; 8108368732,11049 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000002FCD32D330546389 &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_17_____CCR_FGRE_IDX_ZONE_57410_57410_57412_10_15_20580515 &gt;									
	//        &lt; 78lbR9j895ZC5a3y2Z04Kj6Wr8s9Ei7236CxET485ODpmvSyIA7Q27SnM2S8PHa2 &gt;									
	//        &lt; 1E-018 limites [ 8108368732,11049 ; 8321175819,89188 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000003054638931991B4E &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_18_____CCR_FGRE_IDX_ZONE_57410_57410_57412_10_16_20580515 &gt;									
	//        &lt; NNR1l77QKQ3a5tEaUxAK26A78Kzfp7AJ2Nqo51u3ak7M83H27shgv32myO5Rb96c &gt;									
	//        &lt; 1E-018 limites [ 8321175819,89188 ; 9867062217,39601 ] &gt;									
	//        &lt; 0x00000000000000000000000000000000000000000000000031991B4E3ACFF12E &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_19_____CCR_FGRE_IDX_ZONE_57410_57410_57412_10_17_20580515 &gt;									
	//        &lt; M66hG0YE17b5Lh9nNXF2lKHCbI731UT0LPcjN9AsYlyKrg8qKCj6xQ4wN9pMUPC3 &gt;									
	//        &lt; 1E-018 limites [ 9867062217,39601 ; 12054254264,0458 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000003ACFF12E47D95512 &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_20_____CCR_FGRE_IDX_ZONE_57410_57410_57412_10_18_20580515 &gt;									
	//        &lt; F6dTcYF54mvh2956T5EIH2Ky6Ih06T32zb875MYdnfshf8fqZqym7mhu5WnENwWp &gt;									
	//        &lt; 1E-018 limites [ 12054254264,0458 ; 12141416461,2354 ] &gt;									
	//        &lt; 0x00000000000000000000000000000000000000000000000047D95512485E54CE &gt;									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	// Programme d&#39;&#233;mission - Lignes 21 &#224; 30									
	//									
	//									
	//									
	//									
	//     [ Nom du portefeuille ; Num&#233;ro de la ligne ; Nom de la ligne ; Ech&#233;ance ]									
	//         [ Adresse export&#233;e ]									
	//         [ Unit&#233; ; Limite basse ; Limite haute ]									
	//         [ Hex ]									
	//									
	//									
	//									
	//     &lt; FGRE_Portfolio_III_metadata_line_21_____CCR_FGRE_IDX_ZONE_57410_57410_57412_10_19_20580515 &gt;									
	//        &lt; eOyuDPM281HA1XhXx1yCqc0Y6OhBs054QLI2955sTi5E7ptbM694FiR7x5t2c2I8 &gt;									
	//        &lt; 1E-018 limites [ 12141416461,2354 ; 12645420577,3433 ] &gt;									
	//        &lt; 0x000000000000000000000000000000000000000000000000485E54CE4B5F616A &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_22_____CCR_FGRE_IDX_ZONE_57410_57410_57412_10_20_20580515 &gt;									
	//        &lt; TYwWeH83E6rxuvUocRf9E5q8VTdgY4x4ocOHHO1bnH0C7dgZ5w932hmoY8suSgy6 &gt;									
	//        &lt; 1E-018 limites [ 12645420577,3433 ; 14734424601,0189 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000004B5F616A57D2F29C &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_23_____CCR_FGRE_IDX_ZONE_57410_57410_57412_10_21_20580515 &gt;									
	//        &lt; W53PMp8Y93v30g45ALoI4DpK7ba7BJl8Tzm1gOfswHV626i1X2PR623d2L2o3186 &gt;									
	//        &lt; 1E-018 limites [ 14734424601,0189 ; 15323220564,2654 ] &gt;									
	//        &lt; 0x00000000000000000000000000000000000000000000000057D2F29C5B556108 &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_24_____CCR_FGRE_IDX_ZONE_57410_57410_57412_10_22_20580515 &gt;									
	//        &lt; cKo9tYddqTANR67KA7ceZ4YnxG4LCC1zznaPGhOSWDIKVtnLpmytl2qe0lubYWBy &gt;									
	//        &lt; 1E-018 limites [ 15323220564,2654 ; 18048476167,4493 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000005B5561086B93CA01 &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_25_____CCR_FGRE_IDX_ZONE_57410_57410_57412_10_23_20580515 &gt;									
	//        &lt; ARq6s5h04o64kC8F20tt6z62Pne12SLrc5LW813VYnDR18j1xZ8BhZQ8G3886tW0 &gt;									
	//        &lt; 1E-018 limites [ 18048476167,4493 ; 18161194680,6008 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000006B93CA016C3FC8AC &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_26_____CCR_FGRE_IDX_ZONE_57510_57510_6_67_20580515 &gt;									
	//        &lt; 39VR81X7YG5uQQHaLWOFo1QpGsi6vbay2m219Z0fl7lWmUD4JaJ7KMw9O3BA3I99 &gt;									
	//        &lt; 1E-018 limites [ 18161194680,6008 ; 18263154726,7917 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000006C3FC8AC6CDB5CD1 &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_27_____CCR_FGRE_IDX_ZONE_57510_57510_6_68_20580515 &gt;									
	//        &lt; DwiiqfzKVLCMlNSFtt26R4mu5e6FRQ1kPh0CX4utPH6CwiWhkRw8GGDQZ2M2LysC &gt;									
	//        &lt; 1E-018 limites [ 18263154726,7917 ; 18474505984,281 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000006CDB5CD16E1DDBE6 &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_28_____CCR_FGRE_IDX_ZONE_57510_57510_6_70_20580515 &gt;									
	//        &lt; 25I3IDj6Sw2ziN6zs8Fkh48jgre195Ha1YUfLREcUV8d77yDJ43qD1K5AyJJ07wa &gt;									
	//        &lt; 1E-018 limites [ 18474505984,281 ; 20395406096,4228 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000006E1DDBE67990EB82 &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_29_____CCR_FGRE_IDX_ZONE_57510_57510_6_77_20580515 &gt;									
	//        &lt; 8fetqrf8O8BZwYwEhaW0SFx64h4MV811AbYktPUDkrmtJo7s72Z05od280IpX42s &gt;									
	//        &lt; 1E-018 limites [ 20395406096,4228 ; 20507443966,6689 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000007990EB827A3BE04D &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_30_____CCR_FGRE_IDX_ZONE_57510_57510_6_78_20580515 &gt;									
	//        &lt; QuxbipSjNe1AHeop98u6bB7ySu7Bf4Tu3sQy1vzeCWaJV7Gu0783vPytIHJl7qnK &gt;									
	//        &lt; 1E-018 limites [ 20507443966,6689 ; 21459120893,5742 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000007A3BE04D7FE80519 &gt;									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	// Programme d&#39;&#233;mission - Lignes 31 &#224; 40									
	//									
	//									
	//									
	//									
	//     [ Nom du portefeuille ; Num&#233;ro de la ligne ; Nom de la ligne ; Ech&#233;ance ]									
	//         [ Adresse export&#233;e ]									
	//         [ Unit&#233; ; Limite basse ; Limite haute ]									
	//         [ Hex ]									
	//									
	//									
	//									
	//     &lt; FGRE_Portfolio_III_metadata_line_31_____CCR_FGRE_IDX_ZONE_57510_57510_6_79_20580515 &gt;									
	//        &lt; QD63EYIo8YVSCyYR1504fwbeBrTU99I8EcT02CmP8LXqv2947UgVe86m3F7g9jkf &gt;									
	//        &lt; 1E-018 limites [ 21459120893,5742 ; 21868767891,7741 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000007FE8051982591775 &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_32_____CCR_FGRE_IDX_ZONE_57660_18_1_20580515 &gt;									
	//        &lt; d53R50s9udA8Lto1ksfNh488Cf0jng90ok9T37o973P79vZID0M6EPZ7wR3AApTh &gt;									
	//        &lt; 1E-018 limites [ 21868767891,7741 ; 21968088546,7113 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000008259177582F0A497 &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_33_____CCR_FGRE_IDX_ZONE_57660_18_2_20580515 &gt;									
	//        &lt; 7V3ZpPmgRV0oS55b5Y28W4JhHA0GA1WnvW5RDJD38Z02KmK1BHjLW6P28619ocBf &gt;									
	//        &lt; 1E-018 limites [ 21968088546,7113 ; 22099500120,6173 ] &gt;									
	//        &lt; 0x00000000000000000000000000000000000000000000000082F0A49783B9293C &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_34_____CCR_FGRE_IDX_ZONE_57660_18_3_20580515 &gt;									
	//        &lt; U5NPRanjKsma2s827aC0Al9Kh84j8JtYy0b1o9Pw7s6WzKv4VT4BoB5O6Y460Fs1 &gt;									
	//        &lt; 1E-018 limites [ 22099500120,6173 ; 22403905409,0278 ] &gt;									
	//        &lt; 0x00000000000000000000000000000000000000000000000083B9293C8589A58D &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_35_____CCR_FGRE_IDX_ZONE_57660_18_4_20580515 &gt;									
	//        &lt; ym0gBvmaqSVxiozdJ8q78t05xWlKkKAnDY4oq3ZgwUCsUW1kWYhtB4HjiCFJiO0W &gt;									
	//        &lt; 1E-018 limites [ 22403905409,0278 ; 22808944800,977 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000008589A58D87F3B010 &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_36_____CCR_FGRE_IDX_ZONE_57660_18_5_20580515 &gt;									
	//        &lt; qOyZmtkLL6825CQ04j0D5cpxpnj35PWmsbckSt5WBaMKWOY8IvGdFhT2924WpBUX &gt;									
	//        &lt; 1E-018 limites [ 22808944800,977 ;  ] &gt;									
	//        &lt; 0x00000000000000000000000000000000000000000000000087F3B01089601547 &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_37_____CCR_FGRE_IDX_ZONE_57660_18_6_20580515 &gt;									
	//        &lt; F0R0Y97S6kvz6cKruL7XkSd46Bz0qU4zN52I0oNOM3f6R38869O183Bg93DsS564 &gt;									
	//        &lt; 1E-018 limites [ 23047754952,0116 ; 24522859198,0236 ] &gt;									
	//        &lt; 0x00000000000000000000000000000000000000000000000089601547922AE9E0 &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_38_____CCR_FGRE_IDX_ZONE_57660_18_7_20580515 &gt;									
	//        &lt; d238QoI3394Fy3vTv44z4ZtUc7qXofu1KZjr83BM35O5K383oHU5cgtJdIM28y2c &gt;									
	//        &lt; 1E-018 limites [ 24522859198,0236 ; 24692011003,9209 ] &gt;									
	//        &lt; 0x000000000000000000000000000000000000000000000000922AE9E0932D04CC &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_39_____CCR_FGRE_IDX_ZONE_57660_18_8_20580515 &gt;									
	//        &lt; 146U40SOT2N2Ugw4eLVL48x6f69DZGS7Q5K60VziHRZCP29Dd5Hgt4Xxm2RL3sNr &gt;									
	//        &lt; 1E-018 limites [ 24692011003,9209 ; 25027901043,2037 ] &gt;									
	//        &lt; 0x000000000000000000000000000000000000000000000000932D04CC952D8BD8 &gt;									
	//     &lt; FGRE_Portfolio_III_metadata_line_40_____CCR_FGRE_IDX_ZONE_57660_18_9_20580515 &gt;									
	//        &lt; 11aq120KCKs0uySj8xLopPr7g1J9kbYTNy77Ebq0LNINB06S4jhExrRi2DR0E6DB &gt;									
	//        &lt; 1E-018 limites [ 25027901043,2037 ; 26619797430,7234 ] &gt;									
	//        &lt; 0x000000000000000000000000000000000000000000000000952D8BD89EAA965F &gt;									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}