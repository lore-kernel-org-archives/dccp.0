Received: from us-smtp-delivery-44.mimecast.com (us-smtp-delivery-44.mimecast.com [207.211.30.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2AA9315E7E9
	for <dccp@vger.kernel.org>; Fri, 26 Apr 2024 15:13:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=207.211.30.44
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1714144441; cv=none; b=PhWDDjcGvYbhVDxX0QjCKKKAH+AAvjXG8+EWTdwE6r28NOUMj9+JcWyAk7x9fbHt+UjfXUZoKu2GwZ0WRXyfD68Bp0+g6xGx0u0A8C60xLhKFZW+RmPM937eq805cS9TQnf5TtVSC2zSnmlZx5t5vD/T4bW1sMxzmN1e3egtfKQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1714144441; c=relaxed/simple;
	bh=Po3PPn4BB/lBrcPOl81dTbAUjsWkWntrc/48c0CLwmY=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 In-Reply-To:Content-Type:Content-Disposition; b=OiBjQAW7xJc3j7coa2ce6+VE1AVBr+ecBy0uF26p+CLDQy9B/DWGMI/ZPCgiKAbDi3exSV0j6OEBoGaPAosP0uW/CGzXAMjYNIuXnRT9eEJrneI/Hfge9EkZQvMquSQ9/sa+pK3LQGp0TUeP7ckeV9yEnPbO4TJR4IWo/5k1QbI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=queasysnail.net; spf=none smtp.mailfrom=queasysnail.net; arc=none smtp.client-ip=207.211.30.44
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=queasysnail.net
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=queasysnail.net
Received: from mimecast-mx02.redhat.com (mx-ext.redhat.com [66.187.233.73])
 by relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-467-wS_phBE4PzqqRVuSprZ2hw-1; Fri,
 26 Apr 2024 11:13:49 -0400
X-MC-Unique: wS_phBE4PzqqRVuSprZ2hw-1
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.rdu2.redhat.com [10.11.54.6])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mimecast-mx02.redhat.com (Postfix) with ESMTPS id 04A0D1C03353;
	Fri, 26 Apr 2024 15:13:47 +0000 (UTC)
Received: from hog (unknown [10.39.193.137])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 4E8DF2166B31;
	Fri, 26 Apr 2024 15:13:38 +0000 (UTC)
Date: Fri, 26 Apr 2024 17:13:37 +0200
From: Sabrina Dubroca <sd@queasysnail.net>
To: Joel Granados via B4 Relay <devnull+j.granados.samsung.com@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
	Alexander Aring <alex.aring@gmail.com>,
	Stefan Schmidt <stefan@datenfreihafen.org>,
	Miquel Raynal <miquel.raynal@bootlin.com>,
	David Ahern <dsahern@kernel.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Matthieu Baerts <matttbe@kernel.org>,
	Mat Martineau <martineau@kernel.org>,
	Geliang Tang <geliang@kernel.org>,
	Remi Denis-Courmont <courmisch@gmail.com>,
	Allison Henderson <allison.henderson@oracle.com>,
	David Howells <dhowells@redhat.com>,
	Marc Dionne <marc.dionne@auristor.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Xin Long <lucien.xin@gmail.com>,
	Wenjia Zhang <wenjia@linux.ibm.com>,
	Jan Karcher <jaka@linux.ibm.com>,
	"D. Wythe" <alibuda@linux.alibaba.com>,
	Tony Lu <tonylu@linux.alibaba.com>,
	Wen Gu <guwen@linux.alibaba.com>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Anna Schumaker <anna@kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>, Neil Brown <neilb@suse.de>,
	Olga Kornievskaia <kolga@netapp.com>, Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>, Jon Maloy <jmaloy@redhat.com>,
	Ying Xue <ying.xue@windriver.com>, Martin Schiller <ms@dev.tdt.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@netfilter.org>,
	Florian Westphal <fw@strlen.de>, Roopa Prabhu <roopa@nvidia.com>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>,
	Joerg Reuter <jreuter@yaina.de>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dccp@vger.kernel.org,
	linux-wpan@vger.kernel.org, mptcp@lists.linux.dev,
	linux-hams@vger.kernel.org, linux-rdma@vger.kernel.org,
	rds-devel@oss.oracle.com, linux-afs@lists.infradead.org,
	linux-sctp@vger.kernel.org, linux-s390@vger.kernel.org,
	linux-nfs@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	linux-x25@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, bridge@lists.linux.dev,
	lvs-devel@vger.kernel.org, Joel Granados <j.granados@samsung.com>
Subject: Re: [PATCH v5 5/8] net: Remove ctl_table sentinel elements from
 several networking subsystems
Message-ID: <ZivEOtGOWVc0W8Th@hog>
References: <20240426-jag-sysctl_remset_net-v5-0-e3b12f6111a6@samsung.com>
 <20240426-jag-sysctl_remset_net-v5-5-e3b12f6111a6@samsung.com>
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
In-Reply-To: <20240426-jag-sysctl_remset_net-v5-5-e3b12f6111a6@samsung.com>
X-Scanned-By: MIMEDefang 3.4.1 on 10.11.54.6
X-Mimecast-Spam-Score: 0
X-Mimecast-Originator: queasysnail.net
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

2024-04-26, 12:46:57 +0200, Joel Granados via B4 Relay wrote:
> diff --git a/net/smc/smc_sysctl.c b/net/smc/smc_sysctl.c
> index a5946d1b9d60..bd0b7e2f8824 100644
> --- a/net/smc/smc_sysctl.c
> +++ b/net/smc/smc_sysctl.c
> @@ -90,7 +90,6 @@ static struct ctl_table smc_table[] =3D {
>  =09=09.extra1=09=09=3D &conns_per_lgr_min,
>  =09=09.extra2=09=09=3D &conns_per_lgr_max,
>  =09},
> -=09{  }
>  };

There's an ARRAY_SIZE(smc_table) - 1 in smc_sysctl_net_init, shouldn't
the -1 be removed like you did in other patches?


int __net_init smc_sysctl_net_init(struct net *net)
{
=09struct ctl_table *table;

=09table =3D smc_table;
=09if (!net_eq(net, &init_net)) {
=09=09int i;

=09=09table =3D kmemdup(table, sizeof(smc_table), GFP_KERNEL);
=09=09if (!table)
=09=09=09goto err_alloc;

=09=09for (i =3D 0; i < ARRAY_SIZE(smc_table) - 1; i++)
=09=09=09table[i].data +=3D (void *)net - (void *)&init_net;
=09}

=09net->smc.smc_hdr =3D register_net_sysctl_sz(net, "net/smc", table,
=09=09=09=09=09=09  ARRAY_SIZE(smc_table));
[...]

--=20
Sabrina

