Received: from NAM10-DM6-obe.outbound.protection.outlook.com (mail-dm6nam10on2070.outbound.protection.outlook.com [40.107.93.70])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1A414198A29;
	Thu, 16 Jan 2025 14:43:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=40.107.93.70
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1737038620; cv=fail; b=IuERKJJSl4sMn/neWCXdBnMaayuC0dy2bbDQiRJ9GL/t8JPcSNOmx+RkleO4ekFcPJ4nMEVdFrLyiPcCqO4B9MTU8G9P6lxyD/8cnuptY/uAMNcdNLPaiNNf31ZIzDBdqiMy60E5CR5VOcJIHiMtkgHL7AJkB8tW2oEU184ChUI=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1737038620; c=relaxed/simple;
	bh=+1GgaOF9yDkmcFUWDpmQAS4H3oAH6dOMI5qG9klKmGI=;
	h=Date:From:To:Cc:Subject:Message-ID:References:Content-Type:
	 Content-Disposition:In-Reply-To:MIME-Version; b=sgXhnakF5vlN7vuqddwnEqWeEMaIFiwbUHKFWRP5r4xlZOAaVfL7wUtt9EhXMnmadFoq0BsgsrRFeInhoKC5J+4Jupu1rZjJ8Z/bX8IJ/D7+XP1NVzWWh4GgYkNy7gsHz7uVNtbc5AK/voUky6U5j7+BJBS1+YncwPtL3XGwm/o=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com; spf=fail smtp.mailfrom=nvidia.com; dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b=cou3aBbP; arc=fail smtp.client-ip=40.107.93.70
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=nvidia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b="cou3aBbP"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=odXYvap+arymxLdjfNy2E5HehFsRiv9lNTXSHekK79b/Vy31buG4LQp2ZgIpgchIMEUxCggCsqyNTjcMmA8vjkN8Gb4+fzq2PWoRzGI1RHHorA2C+6EDu/c/DZO9j+qvmy2/AdOs736wC34cVTRx66XBE5pl9t8VgZCsL40Ce45iFNNMhuo5W5ZvSmzYFxcHCFbtSpn8SrQIZsCNWdo+FLTwTFWgQTE9oB3PCwYxPN7EuZp6fB5Fz1r35zswWCxO5ohdb6o5VcZ3HnwiWWJ5cKzZuEClCOIavdI2ViRqo68+yH1SP90ZnnBwKMn6zwEHBtzs+LSiT61sHOyh9jsmJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=YqXB2V9d7qcev3lCmBX7cUJFXZLykIFdrmkjMtlkd5A=;
 b=UqHS0SeoIPjbVqVG2xP1VHN7KIlBNZzMIoqZ7aE9VJJkWC5qjviY/KHTMbPvSCHaIFSjdXMQJce4JcNOSJfMDHHYbaVMnIW6acWIrcK7ayy1mQXrWKMSe6BtlQuFYLTbY+WYCkg7lGkQK0BCTAazcV/SDjeLixe9kVCEQAf475COY9Ry8nJHw5ek5o1cefqBs77UNx4iHUcubqLgfsvulBHz0eYNvj3lMH32D7M5bojnO5R/iPjWhS+ElMtd4WHoXwej1IEMCHreGPb9excFjTSKAAqDIaxxM6/dqrQblBzZ/s31UY2ktKxoGUgJn0+5v4+CliDGBDnV/jQuwcoTig==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=nvidia.com; dmarc=pass action=none header.from=nvidia.com;
 dkim=pass header.d=nvidia.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Nvidia.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=YqXB2V9d7qcev3lCmBX7cUJFXZLykIFdrmkjMtlkd5A=;
 b=cou3aBbP5NZ8ijN5WqWXXrO8DkztCGSsIY9oSdSS/4X/dVNe0yggEeMAJPMprymV9WIsAZWgWp4Zv0Q2CL5E/aP+KotfhymWk88QlsyGUkqeh+DmLKviUGx1BPFttPXbbQp/sTBXMXm4sJz5zmxSelxcG37smQwoTYYCXGw/3S4In5dGqWRhZvwVt7+aEsXLXwJmPQZpo8ThBalgO0/Lh742PCoVm9s7VJ78l0+VVqkX5DwZy/dCSfbyZXqG7mbH00sC/WadBWAyvU3K1HcNBVDibYY2tjWuESp1bUN943yNQaPQatysh7ZFiqFD9TkTtF2i8I+WrXnekhYW4OyvVg==
Authentication-Results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=nvidia.com;
Received: from SA3PR12MB7901.namprd12.prod.outlook.com (2603:10b6:806:306::12)
 by SJ2PR12MB8943.namprd12.prod.outlook.com (2603:10b6:a03:547::17) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8356.14; Thu, 16 Jan
 2025 14:43:36 +0000
Received: from SA3PR12MB7901.namprd12.prod.outlook.com
 ([fe80::66fc:f8a2:1bfb:6de8]) by SA3PR12MB7901.namprd12.prod.outlook.com
 ([fe80::66fc:f8a2:1bfb:6de8%4]) with mapi id 15.20.8356.010; Thu, 16 Jan 2025
 14:43:36 +0000
Date: Thu, 16 Jan 2025 16:43:25 +0200
From: Ido Schimmel <idosch@nvidia.com>
To: Guillaume Nault <gnault@redhat.com>
Cc: David Miller <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>, Eric Dumazet <edumazet@google.com>,
	netdev@vger.kernel.org, Simon Horman <horms@kernel.org>,
	dccp@vger.kernel.org
Subject: Re: [PATCH net-next v2] dccp: Prepare dccp_v4_route_skb() to
 .flowi4_tos conversion.
Message-ID: <Z4kbDZDkdTRuCy1P@shredder>
References: <208dc5ca28bb5595d7a545de026bba18b1d63bda.1737032802.git.gnault@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <208dc5ca28bb5595d7a545de026bba18b1d63bda.1737032802.git.gnault@redhat.com>
X-ClientProxiedBy: FR0P281CA0103.DEUP281.PROD.OUTLOOK.COM
 (2603:10a6:d10:a9::16) To SA3PR12MB7901.namprd12.prod.outlook.com
 (2603:10b6:806:306::12)
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: SA3PR12MB7901:EE_|SJ2PR12MB8943:EE_
X-MS-Office365-Filtering-Correlation-Id: ad528e87-c830-4908-b57c-08dd363c2871
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam: BCL:0;ARA:13230040|376014|366016|1800799024|7053199007;
X-Microsoft-Antispam-Message-Info:
	=?us-ascii?Q?bm/tFAr/4z5ooero/KxRuueCqsmazywVhabRoO4OX6fU6hBi0et5IJwRRK/I?=
 =?us-ascii?Q?V67enIpdWoLlL0Ny+FWZ6/GYe7G8vJY0y4RtoAmgQKWDg77RgECOU1SfudRP?=
 =?us-ascii?Q?5YO7XoxufHKgoo8UkVKMsixBe+vSn7rzErdzMsQ6a0ZZYLjU/8PUUeicLCyi?=
 =?us-ascii?Q?IvSJRcihu8uT0hIe0lx34bA2yEeW7FDg2Y3E7yDw3sbctPwbRCdVILxSe61W?=
 =?us-ascii?Q?WpUDaZlMZe8Zy+pQ/aZxysqJegk7EYb2J8csaPwGRA47M/1tUsyIry6rGwu7?=
 =?us-ascii?Q?/IlDiCBx7AVsco/5oz6YQ7AC5rd4kqVQYUhQZBvFTZZkvSB+HpZl11UeHBAi?=
 =?us-ascii?Q?V3aKBiextI84ZFiG/B1EzN40gCm0V7vBjADob16c6trv/LBJbGX5t6ESkczg?=
 =?us-ascii?Q?C8dAWqtBbGU5CFAiGIR/PbDOeyeTal9LHc7GwHiDhdUyl9HYvD5Bz/Au239p?=
 =?us-ascii?Q?7WiXPciGnK6TQAqSHzp4QFKwExl8CAHFRy0irJnnIZ4LhK94LR3neNmoPmi0?=
 =?us-ascii?Q?iJQPb+7RyT8C8O2F7Jt3tYNVtH1zRcBC3fQIpzdUY5yae6JNuE3DVm9fb6ZZ?=
 =?us-ascii?Q?kagXrU/G97RTIZwZz3W+zQ98M3TFlNnkVU4igBOoUJ/2pfW+1mslkUBVenFe?=
 =?us-ascii?Q?xmqaPcT0uzyCnFmassfldsPRvxxmu7PMA6cIo1p+ZQeDtcxBMflalTyIbOfL?=
 =?us-ascii?Q?AF5URmUY3f29w/lRELNrLPGM27Uw3OrdNYsU6cJQrtZCSVR82ZuGjWL9fBKt?=
 =?us-ascii?Q?wTs+weXS9ipiHCkaEft4Q2HkKw5CbITBeBazvJ8CMiYJy2E2MCh7Bj4xY0DP?=
 =?us-ascii?Q?s6dold1tgZI0GXUP0rvdJHngfj6aSBQ1jV2RqhdQgHHaYEKo8wgJJjylN6VB?=
 =?us-ascii?Q?FzxHtFJpuXV9MK29qNi0+q8BFi/FumDuJSAcQrkgugpVNdMNejy/fJRMbIhv?=
 =?us-ascii?Q?R9b73AtZVqI/05hz5iPzMpTBlmrr8CPe/VOiUDGatF98Ov1PaVI0p447c9m8?=
 =?us-ascii?Q?7AANlsLK3AMXRJHBhAG3AoJ8547i1lQIFZnuK8PxaCPnx10Zg9oTQ6op6fir?=
 =?us-ascii?Q?jf4KIUbkJUhp31oOF7CTji2qRWh56caELk3fzViZ7BJYfMyFU+Rj52DAqCt2?=
 =?us-ascii?Q?WXBy1V7laI2+EJtcQkjJP3q9RKcqVDqonoWQ41MD8MyXsm2thX+MCq+OpSfz?=
 =?us-ascii?Q?tzsBVXGVLkzH8U88XgyMMJ3/0ZdwZW5bMwRgvSKfnuv2Dw7lhmLWE8EXjweL?=
 =?us-ascii?Q?rGJpuvNq+RwAIHC4/NQe3+6/jFHvf2MhTuYlZ85pFNfd1lL3/IRfU7fwkC9c?=
 =?us-ascii?Q?+yjoZvNrQCLUaQrVzeOF7oX1M3amg9JZ2MnYugKjYaTKccxCIp5qImosQfDh?=
 =?us-ascii?Q?1ytNm9jaOdelfHTtG1nZQtBtrmRG?=
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:SA3PR12MB7901.namprd12.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(376014)(366016)(1800799024)(7053199007);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?us-ascii?Q?hnY5OygSJq24OxLE0QYWl53mFM1gHGPemPD89eG5DokVVLuUKrJ9JV6Q6is6?=
 =?us-ascii?Q?bDKE+1t0kCzQkMc0Ik3y2MtAz3Lb2CZfF/aj3WRqIwDvHpbAINQIVyeyrOv9?=
 =?us-ascii?Q?TgJJrAxFx+/yT87tw3iXYF3pqy/aoru2kvVK4tGIT7UKdo4ap2NDqZ3f8UXy?=
 =?us-ascii?Q?s3zjn2eWBaBWycc3q6Y2taTDEE8XkbFmpnKuHpjeLdB9M7R1hWBNsLgI90MX?=
 =?us-ascii?Q?U8qBEKSgZCjCjHpADK3KmMbc/IE3LeEpwXs96+bXjIj6gHCda20nJ0DOtl5v?=
 =?us-ascii?Q?Grw0iBFzTWw2OcjSYDL4UMqzE0F9WF0OzwtADxofNDkuRmSghi+djxM65ex8?=
 =?us-ascii?Q?8Bs0gjNlqZbi+9TcpwcqPVitR/8Zz1l3gSqWhpMMwZyFgsXI+rpbVQFo1J4C?=
 =?us-ascii?Q?QLkd4zJr1AHoGq2GUHOzscThECs6A1ildQqP7iwpMYWFSpuneX1NxoEjN+Fo?=
 =?us-ascii?Q?Ee87X0hm6rYwsiPyYSPy10/32H36Ryko/W+g70ooW//uO2wMMRYdtHN48g1B?=
 =?us-ascii?Q?6/2KBAawB3x7xVXVe/Qh/NBAvHfKNw0uhJcfu0b59wZBdS1A6EHTHrhBxdTN?=
 =?us-ascii?Q?FkQbxn4f9dkwX0pcoDeRd0hXYsZuP/VTZgxysLw0gA0emEp4TutM4hEQ3gsx?=
 =?us-ascii?Q?wieB5Bm35PDyS9h8uYXwCVnhDmJ/APAEw6qNEUJY19dByNLAXZGmZfz8Uf4b?=
 =?us-ascii?Q?Gw+yWPvm6cEPixgOwANT6ayt60WXmBCVlBla3V3x4uRCH+4tuoJGHtzOmA9q?=
 =?us-ascii?Q?kBjGGGB2nk9Tfeq0KWob6xmc130N2aQtHv203DqBfYr6/4g3smHAKjzllivl?=
 =?us-ascii?Q?bFX5qKO02Rnv75kkzxHBkNIArelFnjuDUaz6SxoQXg2lWqTb7RVaQSZBkyjT?=
 =?us-ascii?Q?Ihnrx+X+1RB/YfC7nM8VXJ52CP6x3GCmJDAmp6PvpFPwWKBVl4MjCBv4k1aa?=
 =?us-ascii?Q?Vle+t5TbhDB+BCzJIQlhCfh82infWx4Mf5HOoy8G7AkUTF4uIcTF0xKrqW7t?=
 =?us-ascii?Q?7DaKjUjbPtEcDDgz6csH2mS6m6q4L5nQI00fLQaAAvuIx9jfoLxW6QMldXxr?=
 =?us-ascii?Q?ql8fD2sjrmGH05rCo3+5AjAdXbiBveyXBlZ7gdjIIZqc9pOnR1JdDJwJUBUH?=
 =?us-ascii?Q?8/v+q34ZGv6d6L8GwiOaKMZzCkjDCbmfY8IhpEgf4r/4kkp79b/Atwsr+tpG?=
 =?us-ascii?Q?UH76A682LR40bolbJcvdIVZpuobVtWI2xwl4i7ynmYzh11o+eJaPVCnzh8cQ?=
 =?us-ascii?Q?9VcSn8I5vSjM9TtglJRBvJOmlmDqRyIgI+WAkWmYEZQoWtKBOxhZHBEPAOZY?=
 =?us-ascii?Q?qnQPqp+FOJ15IW4JYd7oC4DqqeXt7ORrqHmOSgy9KwcHqfZ+b6OpdoSRwZNv?=
 =?us-ascii?Q?p5IkPgsyPZsqj7nS6rYfoyUEofgrQ6hAMkb3KvxC1n/xF+k7WLgBghjX5siL?=
 =?us-ascii?Q?y0/Qmu/3kFIT8etO3Xc+xrkUmfuR+Omh5zS9PpAznaTTAhfd4JkQR9PMIAtW?=
 =?us-ascii?Q?ARUWAZDcsEEtDIp3Fejtqn+qv3/3lSN/vdaXMspl6bESUBtPQTi2lN0XUA8l?=
 =?us-ascii?Q?0FMwanBV6vfPASKjzVDZWPL+fENeVDVtoTq5/+S0?=
X-OriginatorOrg: Nvidia.com
X-MS-Exchange-CrossTenant-Network-Message-Id: ad528e87-c830-4908-b57c-08dd363c2871
X-MS-Exchange-CrossTenant-AuthSource: SA3PR12MB7901.namprd12.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 16 Jan 2025 14:43:36.1913
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 43083d15-7273-40c1-b7db-39efd9ccc17a
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: 3/+K6Fdz1Hdf3s3vm/cMX8aOkza3MkpSYH1Q54q68IbnHxfW1bOY4i08q0aNv7P2yNsaysS21DOPtPZnxF326Q==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SJ2PR12MB8943

On Thu, Jan 16, 2025 at 02:10:16PM +0100, Guillaume Nault wrote:
> Use inet_sk_dscp() to get the socket DSCP value as dscp_t, instead of
> ip_sock_rt_tos() which returns a __u8. This will ease the conversion
> of fl4->flowi4_tos to dscp_t, which now just becomes a matter of
> dropping the inet_dscp_to_dsfield() call.
> 
> Signed-off-by: Guillaume Nault <gnault@redhat.com>

Reviewed-by: Ido Schimmel <idosch@nvidia.com>
