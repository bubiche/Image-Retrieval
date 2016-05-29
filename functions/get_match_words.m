function matched = get_match_words(x, y)
    matched = zeros(2, 0);
    for i = 1:numel(x)
        index = find(y == x(i));
        tmp = [repmat(i, 1, numel(index)); index];
        matched = horzcat(matched, tmp);
    end
end