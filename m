From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 27 Sep 2007 08:49:06 +0000
Subject: Re: Towards the ccid-3 and ccid-4 integration
Message-Id: <5640c7e00709270149u269306dbm7b693f903d321bd0@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570709241115u1254baa9j7033d1bdc9dc079@mail.gmail.com>
In-Reply-To: <5bc4c4570709241115u1254baa9j7033d1bdc9dc079@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/27/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
>  * but there is already dccp_tfrc_lib which hosts a major number of functions used by CCID3/4
>  * hence I think that you could proceed by
>         - add a CCID-3 specific object file to dccp_tfrc_lib-y in net/dccp/ccids/lib/Makefile
>           (eg. ccid3_funcs.o or whatever)
>         - the file could take the shared functions, ccid3.c could then be stripped to smaller functions
>           which wrap around the library functions
>         - tfrc.h could take the declarations
>  * this way one library less to look after.
>
I agree. I came up with this idea too and then I promptly forgot it!

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
