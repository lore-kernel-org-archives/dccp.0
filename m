Received: from Chamillionaire.breakpoint.cc (Chamillionaire.breakpoint.cc [91.216.245.30])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2EB4419539C;
	Fri, 14 Jun 2024 10:55:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=91.216.245.30
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1718362506; cv=none; b=aKAxNQY5honxgdQmgH7mS4CKSZlKTJxfBZsw/gAoUyTZ+lwAbnv5sFQFQ6aksghxB3nVwzAbW+hjg8+flLzWP+2f0W4rC5rvqy5w9Crq870MbXjmY7LlZEr2qYHC5BWqEc3DnVWXV+bOMydvlD61hBTFZakCPYa0a8Cls80koG4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1718362506; c=relaxed/simple;
	bh=AC6asnkFXpU0r0Pl9EyslQA5xfu3UdgVgxcdXZ6lmFc=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=sNcOhsqSWi62TN9f8vG8uWFHfinbpJglin4eXcTmxKWeMQ6TZxSdJgFp+WXHfknbcqDmt+k3Zx1ixvo8B51+WqCsWQp0IWn2rM9gTZEPA3EzgCgSmPVBhZ1WmHbhtzQcnYSkKN3ed5NareZEiWei+skFeRKm1GQt4pJLzLbjx1E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=strlen.de; spf=pass smtp.mailfrom=strlen.de; arc=none smtp.client-ip=91.216.245.30
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=strlen.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=strlen.de
Received: from fw by Chamillionaire.breakpoint.cc with local (Exim 4.92)
	(envelope-from <fw@strlen.de>)
	id 1sI4Zt-0006X8-Cb; Fri, 14 Jun 2024 12:54:41 +0200
Date: Fri, 14 Jun 2024 12:54:41 +0200
From: Florian Westphal <fw@strlen.de>
To: luoxuanqiang <luoxuanqiang@kylinos.cn>
Cc: edumazet@google.com, davem@davemloft.net, dsahern@kernel.org,
	fw@strlen.de, kuba@kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, pabeni@redhat.com, kuniyu@amazon.com,
	dccp@vger.kernel.org
Subject: Re: [PATCH net v2] Fix race for duplicate reqsk on identical SYN
Message-ID: <20240614105441.GA24596@breakpoint.cc>
References: <20240614102628.446642-1-luoxuanqiang@kylinos.cn>
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20240614102628.446642-1-luoxuanqiang@kylinos.cn>
User-Agent: Mutt/1.10.1 (2018-07-13)

luoxuanqiang <luoxuanqiang@kylinos.cn> wrote:
>  include/net/inet_connection_sock.h |  2 +-
>  net/dccp/ipv4.c                    |  2 +-
>  net/dccp/ipv6.c                    |  2 +-
>  net/ipv4/inet_connection_sock.c    | 15 +++++++++++----
>  net/ipv4/tcp_input.c               | 11 ++++++++++-
>  5 files changed, 24 insertions(+), 8 deletions(-)
> 
> diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
> index 7d6b1254c92d..8773d161d184 100644
> --- a/include/net/inet_connection_sock.h
> +++ b/include/net/inet_connection_sock.h
> @@ -264,7 +264,7 @@ struct sock *inet_csk_reqsk_queue_add(struct sock *sk,
>  				      struct request_sock *req,
>  				      struct sock *child);
>  void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
> -				   unsigned long timeout);
> +				   unsigned long timeout, bool *found_dup_sk);

Nit:

I think it would be preferrable to change retval to bool rather than
bool *found_dup_sk extra arg, so one can do

bool inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
  				   unsigned long timeout)
{
	if (!reqsk_queue_hash_req(req, timeout))
		return false;

i.e. let retval indicate wheter reqsk was inserted or not.

Patch looks good to me otherwise.
