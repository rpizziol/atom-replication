function timestamp = getDateString()
%GETDATESTRING Get current date/time in the format: 'YYYYMMDD-HHMMSS'
    c = clock;
    year = sprintf('%04d', c(1));
    month = sprintf('%02d', c(2));
    day = sprintf('%02d', c(3));
    hour = sprintf('%02d', c(4));
    minute = sprintf('%02d', c(5));
    seconds = sprintf('%02d', round(c(6)));
    timestamp = strcat(year, month, day, '-', hour, minute, seconds);
end

