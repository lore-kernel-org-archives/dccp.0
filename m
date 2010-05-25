From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 25 May 2010 11:23:07 +0000
Subject: Re: [PATCH 22/27] net/dccp: Use memdup_user
Message-Id: <20100525112307.GA5528@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <Pine.LNX.4.64.1005221025040.13021@ask.diku.dk>
In-Reply-To: <Pine.LNX.4.64.1005221025040.13021@ask.diku.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| Signed-off-by: Julia Lawall <julia@diku.dk>
Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

| 
| ---
|  net/dccp/proto.c |   11 +++--------
|  1 file changed, 3 insertions(+), 8 deletions(-)
| 
| diff --git a/net/dccp/proto.c b/net/dccp/proto.c
| index b03ecf6..f79bcef 100644
| --- a/net/dccp/proto.c
| +++ b/net/dccp/proto.c
| @@ -473,14 +473,9 @@ static int dccp_setsockopt_ccid(struct sock *sk, int type,
|  	if (optlen < 1 || optlen > DCCP_FEAT_MAX_SP_VALS)
|  		return -EINVAL;
|  
| -	val = kmalloc(optlen, GFP_KERNEL);
| -	if (val = NULL)
| -		return -ENOMEM;
| -
| -	if (copy_from_user(val, optval, optlen)) {
| -		kfree(val);
| -		return -EFAULT;
| -	}
| +	val = memdup_user(optval, optlen);
| +	if (IS_ERR(val))
| +		return PTR_ERR(val);
|  
|  	lock_sock(sk);
|  	if (type = DCCP_SOCKOPT_TX_CCID || type = DCCP_SOCKOPT_CCID)
