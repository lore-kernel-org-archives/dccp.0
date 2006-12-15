From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 15 Dec 2006 21:42:14 +0000
Subject: Re: [PATCH 2/8]: Signed variant of dccp_delta_seqno
Message-Id: <5640c7e00612151342r3ced99f2ndc41d031961557b6@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612151050.08430@strip-the-willow>
In-Reply-To: <200612151050.08430@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/15/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Make dccp_delta_seqno return signed numbers
>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

We will need to check callers of dccp_delta_seqno due to the sign
change of return.
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
