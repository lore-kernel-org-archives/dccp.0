From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 24 Jan 2007 00:57:39 +0000
Subject: Re: [PATCH 2/7]: Wrap computation of RFC3390-initial rate into separate function
Message-Id: <5640c7e00701231657p4f34551p1078a8dedb993221@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200701231540.51401@strip-the-willow>
In-Reply-To: <200701231540.51401@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 24/01/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID 3]: Wrap computation of RFC3390-initial rate into separate function
> +static inline u64 rfc3390_initial_rate(struct sock *sk)

Apart from in header files which already exist you shouldn't be
putting new inline functions in as per a number of discussions on
lkml. The reason for this is that gcc now decides itself when to
inline code and when not to.

Once this is fixed - Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web: http://wand.net.nz/~iam4
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
