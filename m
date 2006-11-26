From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sun, 26 Nov 2006 04:14:38 +0000
Subject: Re: [PATCH 1/6]: Fix bug in calculation of first t_nom and first t_ipi
Message-Id: <5640c7e00611252014p3bdd2662hc658446123d99b5c@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611211545.07412@strip-the-willow>
In-Reply-To: <200611211545.07412@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/26/06, Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com> wrote:
> On 11/22/06, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> > >   However, I think your point is valid and we should add a ToDo for that section
> > >   of code which re-adjusts the sending rate after the first feedback packet has arrived.
> > >
> > Thanks for checking this and I agree with your conclusions.
>
> Can you please provide a Signed-off-by for this one?
>
> - Arnaldo
>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
