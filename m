From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Sun, 26 Nov 2006 03:27:09 +0000
Subject: Re: [PATCH 1/6]: Fix bug in calculation of first t_nom and first t_ipi
Message-Id: <39e6f6c70611251927i4f6266cwd281cbcaed31ec4f@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611211545.07412@strip-the-willow>
In-Reply-To: <200611211545.07412@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/22/06, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> >   However, I think your point is valid and we should add a ToDo for that section
> >   of code which re-adjusts the sending rate after the first feedback packet has arrived.
> >
> Thanks for checking this and I agree with your conclusions.

Can you please provide a Signed-off-by for this one?

- Arnaldo
