From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 29 Aug 2008 06:57:06 +0000
Subject: Re: [PATCH 14/37] dccp: Tidy up setsockopt calls
Message-Id: <20080829065706.GH3557@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1219945512-7723-15-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1219945512-7723-15-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > This splits the setsockopt calls into two groups, depending on whether an
| > integer argument (val) is required and whether routines being called do
| > their own locking.
| > 
| > Some options (such as setting the CCID) use u8 rather than int, so that for
| > these the test with regard to integer-sizeof can not be used.
| > 
| > The second switch-case statement now only has those statements which need
| > locking and which make use of `val'.
| > 
<snip>
| > --- a/net/dccp/proto.c
| > +++ b/net/dccp/proto.c
| > @@ -511,26 +511,27 @@ static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
| >  	struct dccp_sock *dp = dccp_sk(sk);
| >  	int val, err = 0;
| >  
| > -	if (optlen < sizeof(int))
| > -		return -EINVAL;
| > -
| > -	if (get_user(val, (int __user *)optval))
| > -		return -EFAULT;
| > -
| > -	if (optname = DCCP_SOCKOPT_SERVICE)
| > -		return dccp_setsockopt_service(sk, val, optval, optlen);
| > -
| > -	lock_sock(sk);
| >  	switch (optname) {
| >  	case DCCP_SOCKOPT_PACKET_SIZE:
| >  		DCCP_WARN("sockopt(PACKET_SIZE) is deprecated: fix your app\n");
| > -		err = 0;
| > -		break;
| > +		return 0;
| >  	case DCCP_SOCKOPT_CHANGE_L:
| >  	case DCCP_SOCKOPT_CHANGE_R:
| >  		DCCP_WARN("sockopt(CHANGE_L/R) is deprecated: fix your app\n");
| > -		err = 0;
| > -		break;
| > +		return 0;
| > +	default:
| > +		if (optlen < sizeof(int))
| > +			return -EINVAL;
| > +
| > +		if (get_user(val, (int __user *)optval))
| > +			return -EFAULT;
| > +
| > +		if (optname = DCCP_SOCKOPT_SERVICE)
| > +			return dccp_setsockopt_service(sk, val, optval, optlen);
| 
| What is in the default could well continue outside the switch
| statatement, since all the other cases return directly.
| 
Would you be ok to return to this question at a later stage? - agreed
that there is potential here to unify things. I have not done much here
for the main reason that most of the API is still open for people to
define, i.e. although this patch set is about a new API, there is
actually only a single new setsockopt functionality -- for
setting/getting the CCID. 

Since the old mechanism (struct dccp_so_feat) has been removed, there
is potential for making up a complete new API, but the patch set does
not do much in this way, so input/discussion would be good.

| > +	}
| > +
| > +	lock_sock(sk);
| > +	switch (optname) {
| >  	case DCCP_SOCKOPT_SERVER_TIMEWAIT:
| >  		if (dp->dccps_role != DCCP_ROLE_SERVER)
| >  			err = -EOPNOTSUPP;
| > @@ -547,8 +548,8 @@ static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
| >  		err = -ENOPROTOOPT;
| >  		break;
| >  	}
| > -
| >  	release_sock(sk);
| > +
| >  	return err;
| >  }
