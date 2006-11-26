From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sun, 26 Nov 2006 20:28:59 +0000
Subject: Re: [PATCH 1/10]: Avoid congestion control on zero-sized data packets
Message-Id: <5640c7e00611261228m5bb1ff92i800f9262a7abf9ca@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611241619.13603@strip-the-willow>
In-Reply-To: <200611241619.13603@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/25/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID 3]: Avoid congestion control on zero-sized data packets
>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

I think in both of these functions we should change len to unsigned or
make more explicit checks as we can have problems with negative
integers. This already exists though so patch causes no further
problems and tidies things up.

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
