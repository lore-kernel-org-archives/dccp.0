From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sun, 26 Nov 2006 20:47:17 +0000
Subject: Re: [PATCH 5/10]: Consistently update t_nom, t_ipi, t_delta
Message-Id: <5640c7e00611261247h1371b586u8f224f250f4cee3c@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611241619.41268@strip-the-willow>
In-Reply-To: <200611241619.41268@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/25/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID 3] Consistently update t_nom, t_ipi, t_delta
>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

>  * ties updating these parameters to updating the sending rate X, exploiting
>    that all three parameters in turn depend on X; and using a small optimisation
>    which can reduce the number of required instructions: only update the three
>    parameters when X really changes
>
Do we need to worry about s changing though with the other patches you
have introduced as it is also dependent on s....

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
