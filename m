From: "Leandro Sales" <leandroal@gmail.com>
Date: Wed, 26 Dec 2007 18:01:29 +0000
Subject: Re: [PATCHv2 4/8] Fix name schema for tx-rx sock struct
Message-Id: <5bc4c4570712261001u2d02b5b0x41b174289b70a9a8@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200712210133.16344.leandroal@gmail.com>
In-Reply-To: <200712210133.16344.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Gerrit,
   the patches was applied against:

# git-describe
v2.6.23-rc6-10457-g5ff93cc

SHA1 ID: 5ff93cc505b6ced6aa6d4c65df6d9beb6ae10fac

I cloned it at 2007-12-20, 18:19:49 (GMT -3).

Leandro.

2007/12/21, Gerrit Renker <gerrit@erg.abdn.ac.uk>:
> And your naming scheme changed from version 1 to version 2:
>
> This is patch v2:
> |       switch (optname) {
> |       case DCCP_SOCKOPT_CCID_TX_INFO:
> | -             if (len < sizeof(hctx->tfrchctx_tfrc))
> | +             if (len < sizeof(hctx->ttx_tfrc))
> |                       return -EINVAL;
> | -             len = sizeof(hctx->tfrchctx_tfrc);
> | -             val = &hctx->tfrchctx_tfrc;
> | +             len = sizeof(hctx->ttx_tfrc);
> | +             val = &hctx->ttx_tfrc;
> |               break;
>
> ... and this is patch v1:
>
> |       switch (optname) {
> |       case DCCP_SOCKOPT_CCID_TX_INFO:
> | -             if (len < sizeof(hctx->tfrchctx_tfrc))
> | +             if (len < sizeof(hctx->tfrc_tx))
> |                       return -EINVAL;
> | -             len = sizeof(hctx->tfrchctx_tfrc);
> | -             val = &hctx->tfrchctx_tfrc;
> | +             len = sizeof(hctx->tfrc_tx);
> | +             val = &hctx->tfrc_tx;
> |               break;
> 'tfrc_tx' becomes 'ttx_tfrc'. I think that is all needs more work and in
> particular discussion with Arnaldo.
>
> With the given inconsistencies I can't put the set into the test tree.
> Can you please resolve the naming scheme inconsistencies and the version
> problems and resubmit a fresh patch set after discussing with Arnaldo.
>


-- 
Leandro Melo de Sales.
Pervasive and Embedded Computing Laboratory
BRisa and E-Phone Projects Manager
Network Admin @ http://embedded.ufcg.edu.br/indexen.html
+55 83 3310-1404 (extension 208)

"There are 10 types of people in this world: those who understand
binary, those who don't"
