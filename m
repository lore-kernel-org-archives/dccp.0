From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 28 Nov 2006 21:01:42 +0000
Subject: Re: [PATCH 2/2]: Use `unsigned' for packet lengths
Message-Id: <5640c7e00611281301y290dfbeej69b130854757311d@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611281435.05466@strip-the-willow>
In-Reply-To: <200611281435.05466@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/29/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> This is a re-sent after discussion which
>   * changes the types to `unsigned int'
>   * removes the third argument of ccid_hc_tx_send_packet
>     since it is always set to skb->len
>
> I double-checked this once, and compile-tested it.
> Gerrit
>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Great work Gerrit. Really appreciated all this tidying up as well.

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
