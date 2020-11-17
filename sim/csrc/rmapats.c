// file = 0; split type = patterns; threshold = 100000; total count = 0.
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include "rmapats.h"

void  hsG_0__0 (struct dummyq_struct * I1294, EBLK  * I1288, U  I685);
void  hsG_0__0 (struct dummyq_struct * I1294, EBLK  * I1288, U  I685)
{
    U  I1552;
    U  I1553;
    U  I1554;
    struct futq * I1555;
    struct dummyq_struct * pQ = I1294;
    I1552 = ((U )vcs_clocks) + I685;
    I1554 = I1552 & ((1 << fHashTableSize) - 1);
    I1288->I727 = (EBLK  *)(-1);
    I1288->I731 = I1552;
    if (I1552 < (U )vcs_clocks) {
        I1553 = ((U  *)&vcs_clocks)[1];
        sched_millenium(pQ, I1288, I1553 + 1, I1552);
    }
    else if ((peblkFutQ1Head != ((void *)0)) && (I685 == 1)) {
        I1288->I733 = (struct eblk *)peblkFutQ1Tail;
        peblkFutQ1Tail->I727 = I1288;
        peblkFutQ1Tail = I1288;
    }
    else if ((I1555 = pQ->I1195[I1554].I745)) {
        I1288->I733 = (struct eblk *)I1555->I744;
        I1555->I744->I727 = (RP )I1288;
        I1555->I744 = (RmaEblk  *)I1288;
    }
    else {
        sched_hsopt(pQ, I1288, I1552);
    }
}
#ifdef __cplusplus
extern "C" {
#endif
void SinitHsimPats(void);
#ifdef __cplusplus
}
#endif
