From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 10 Apr 2007 23:20:40 +0000
Subject: Re: [PATCH 39/43]: Protect against Reset/Sync floods due to buggy applications
Message-Id: <5640c7e00704101620t3353a873ke328e4da3e0eb30c@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200704051637.18198@strip-the-willow>
In-Reply-To: <200704051637.18198@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 4/9/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
>  * the bug and its cause are documented on
>       http://www.erg.abdn.ac.uk/users/gerrit/dccp/docs/seqno_bug/
>    (in short, the Sync did not acknowledge GSR, but rather P.seqno);
>

Yes I had noticed that bug also at times and never quite got around to
fixing it. Will have to read more about rate limiting though as I'm
not convinced normally about rate limiting schemes etc as they
invariably end up causing problems when doing things like running a
huge server with lots of connections. However as I said, haven't read
it yet so might be wrong on your intent.

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
