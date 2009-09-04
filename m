From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Fri, 04 Sep 2009 15:45:13 +0000
Subject: Re: [PATCH 5/5] Updating documentation accordingly
Message-Id: <20090904084513.8a35dc71.randy.dunlap@oracle.com>
List-Id: <dccp.vger.kernel.org>
References: <cb00fa210909011946g744a4f5cvbe6a2e7642eaa8ff@mail.gmail.com>
In-Reply-To: <cb00fa210909011946g744a4f5cvbe6a2e7642eaa8ff@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Fri, 04 Sep 2009 09:25:11 -0300 Ivo Calado wrote:

> Updating documentation accordingly
> 
> Signed-off-by: Ivo Calado, Erivaldo Xavier, Leandro Sales
> <ivocalado@embedded.ufcg.edu.br>, <desadoc@gmail.com>,
> <leandroal@gmail.com>
> 
> Index: dccp_tree_work4/net/dccp/ccids/lib/loss_interval_sp.c
> =================================> --- dccp_tree_work4.orig/net/dccp/ccids/lib/loss_interval_sp.c
> 2009-09-04 00:28:03.000000000 -0300
> +++ dccp_tree_work4/net/dccp/ccids/lib/loss_interval_sp.c 2009-09-04
> 01:00:22.000000000 -0300
> @@ -324,7 +342,7 @@
> }
> 
> /**
> - * tfrc_lh_update_i_mean  -  Update the `open' loss interval I_0
> + * tfrc_sp_lh_update_i_mean  -  Update the `open' loss interval I_0
>   * This updates I_mean as the sequence numbers increase. As a
> consequence, the
>   * open loss interval I_0 increases, hence p = W_tot/max(I_tot0,
> I_tot1)
>   * decreases, and thus there is no need to send renewed feedback.
> @@ -372,7 +390,7 @@
> return cur->li_is_closed;
> }
> 
> -/** tfrc_lh_interval_add  -  Insert new record into the Loss Interval
> database
> +/** tfrc_sp_lh_interval_add - Insert new record into the Loss Interval
> database

The beginning kernel-doc marker ("/**") should be on a line by itself,
like all of the others are.


>   * @lh:    Loss Interval database
>   * @rh:    Receive history containing a fresh loss event
>   * @calc_first_li: Caller-dependent routine to compute length of first
> interval

> Index: dccp_tree_work4/net/dccp/ccids/lib/tfrc_equation_sp.c
> =================================> --- dccp_tree_work4.orig/net/dccp/ccids/lib/tfrc_equation_sp.c
> 2009-09-03 22:01:08.000000000 -0300
> +++ dccp_tree_work4/net/dccp/ccids/lib/tfrc_equation_sp.c 2009-09-04
> 00:54:05.000000000 -0300
> @@ -607,7 +609,7 @@
> }
> 
> /**
> - * tfrc_calc_x - Calculate the send rate as per section 3.1 of RFC3448
> + * tfrc_sp_calc_x - Calculate the send rate as per section 3.1 of
> RFC3448

Looks like some mail-handling software is splitting lines where they
should not be split.  You should check that the mailed patches (on the
receiving side) can be applied cleanly.


>   *
>   *  @s: packet size          in bytes
>   *  @R: RTT                  scaled by 1000000   (i.e., microseconds)



---
~Randy
LPC 2009, Sept. 23-25, Portland, Oregon
http://linuxplumbersconf.org/2009/
