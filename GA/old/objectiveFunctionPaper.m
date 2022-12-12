function of = objectiveFunctionPaper(s, thr, N, wm)
    wb = getMix(wm);
    thrMax = N * 1000 / (7000 + 1.2 + wb(1) * 1.2 + ...
        wb(2) * (3.7 + 2.2 + 1.9 + 2.6) + ...
        wb(3) * (4.9 + 17.4 + 5.6 + 6.6));
    psi = 0.5;
    of = psi * (thr / thrMax) - (1 - psi) * (s / 20);
end

