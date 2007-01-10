From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 10 Jan 2007 01:39:33 +0000
Subject: Re: [PATCH 2/5]: DCCP Recalc on non-loss intervals
Message-Id: <5640c7e00701091739w37c593ecnc08a6646e55922e0@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612201545.39441.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612201545.39441.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> One nit.  If you are following RFC terminology i_tot0 should include non_loss,
> but in the code i_tot1 does.  The code seems correct except for the switching
> of i_tot0 and i_tot1.
>
> Eddie

You're right here and I think this is contributing to much of the
confusion as I read through Gerrit's most recent emails.

I'm reworking this patch at present and adding quite a few comments.

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
