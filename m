From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 06 Dec 2007 14:07:34 +0000
Subject: Re: [RFC2][PATCH 7/7] [TFRC]: New rx history code
Message-Id: <20071206140734.GW4653@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <20071206130309.GU4653@ghostprotocols.net>
In-Reply-To: <20071206130309.GU4653@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Thu, Dec 06, 2007 at 02:02:25PM +0000, Gerrit Renker escreveu:
> | 	The first six patches in this series are unmodified, so if you
> | are OK with them please send me your Signed-off-by.
> Patches [1/7], [2/7], and [6/7] already have a signed-off and there are
> no changes. Just acknowledged [3..5/7], will look at [7/7] now.

OK, please let me know if there are still any problems.

The removal of timestamp insertion in ccid3_hc_rx_insert_options will be
put in another cset.

- Arnaldo
