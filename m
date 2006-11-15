From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 15 Nov 2006 17:38:32 +0000
Subject: Re: CCID3: dead code in ccid3_hc_rx_packet_recv?
Message-Id: <5640c7e00611150938v5c88900ag617ce863b7794e73@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <39e6f6c70611150714q5a87fafbld0425ddb4181f28a@mail.gmail.com>
In-Reply-To: <39e6f6c70611150714q5a87fafbld0425ddb4181f28a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/16/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> |  Anyway I'll have a look at it as I can but feel free to make patches.
> |  If you're removing chunks of code I'd prefer it commented out in the
> |  meantime rather than removed.
> Thanks - I was hoping for your answer. To me it seemed that the bidirectional
> processing (node is both receiver and sender) is not supported at the moment
> and that therefore it would make sense to keep tx/rx functionality separate.
>
You are correct there that it is one directional.

-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
