Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3A36916DEAC;
	Tue,  7 May 2024 19:18:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1715109515; cv=none; b=FQPY83EQLd6D44z/rIi4LPNQrlIJg5JPxSyiycWaLH6kfLVKhmWOMifHrVCgk5HExBaI16TLah8y+st8iMQEXdeD4HN1feNbmawztgy65VuaaLpkrJvky3Fnay67guc/Z3k97ujyYFMy/QMJAVwdF6f9p0OAAOzU/quyB5ZmFMI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1715109515; c=relaxed/simple;
	bh=uUZ0wRwqvt5AN23IbqpgPVlEjLnvM1VT4sztb1JpTlI=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=ETYQJx/Xl0NO6tNLPCSe39j/R8D9fcQldozjiZPnh8SNBoWPcCbb4UoJEaa88F5M2W7RcCcsuJ7MgwUE9H3dMCspUhY327dAOHSeSzNCSEd5al6znF0Bv4daSbvhJV+5rVfxwTZwgTSwR2ajtK17CftllQ7HvTeHNxiJi4NxT9w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=EdEN10G4; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="EdEN10G4"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C4848C2BBFC;
	Tue,  7 May 2024 19:18:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1715109514;
	bh=uUZ0wRwqvt5AN23IbqpgPVlEjLnvM1VT4sztb1JpTlI=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=EdEN10G4X60VAwSbDobYx6poRz4kq/eSzLRO2um3y7rzL/h+t24eZgSqM3uit0SK/
	 SiG+czgg6+nb/RQs8KEfD/qoNMyNnBPmIlshItMhm3GZpiCRDB+z0MUNcIk9nNe7bV
	 /P2YVhWh4+g+xCCEX/mzEd2YpWpzy+oDsNLNsQZYyEZi9V+TK3XB4YptFn/Ci79JQQ
	 gTQfmh4dBrqutvk0HsVQ+4EKxhY1Ss/EL7/Lbumpl2Wb5dJ4/4Hhn8kfryxNu0zKq0
	 BLC/nueAXuuyvcafDLcs7SU4q0Cpgl20cDz8wxmbhx6UnZXHx3NtoHtVjZTkQrrTXd
	 4SSsGI8P5fFdQ==
Date: Tue, 7 May 2024 20:17:00 +0100
From: Simon Horman <horms@kernel.org>
To: Jeff Johnson <quic_jjohnson@quicinc.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
	dccp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] net: dccp: Fix ccid2_rtt_estimator() kernel-doc
Message-ID: <20240507191700.GJ15955@kernel.org>
References: <20240505-ccid2_rtt_estimator-kdoc-v1-1-09231fcb9145@quicinc.com>
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20240505-ccid2_rtt_estimator-kdoc-v1-1-09231fcb9145@quicinc.com>

On Sun, May 05, 2024 at 01:09:31PM -0700, Jeff Johnson wrote:
> make C=1 reports:
> 
> warning: Function parameter or struct member 'mrtt' not described in 'ccid2_rtt_estimator'
> 
> So document the 'mrtt' parameter.
> 
> Signed-off-by: Jeff Johnson <quic_jjohnson@quicinc.com>

Reviewed-by: Simon Horman <horms@kernel.org>

The comment just inside tcp_rtt_estimator is a good read :)
