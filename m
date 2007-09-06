From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 06 Sep 2007 04:39:20 +0000
Subject: Re: [PATCH 6/10]: Reduce the number of writable states
Message-Id: <5640c7e00709052139i55f3fc73lb8cca45517ba912e@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 7/13/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Reduce the number of writable states
>
> Since DCCP requires to close both ends of a connection simultaneously,
> permission to write in state DCCP_CLOSING is removed in dccp_sendmsg():
>  * if the sending end closed, it would encounter a write error anyhow;
>  * if the other end has closed the connection, it accepts no more data.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
