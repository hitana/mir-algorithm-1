/++
+/
module mir.ndslice.sorting;

import mir.ndslice.slice;
import mir.ndslice.internal;

@fastmath:

/**
Checks whether a slice is sorted according to the comparison
operation $(D less). Performs $(BIGOH ndslice.elementsCount) evaluations of `less`.
Unlike `isSorted`, $(LREF isStrictlyMonotonic) does not allow for equal values,
i.e. values for which both `less(a, b)` and `less(b, a)` are false.
With either function, the predicate must be a strict ordering just like with
`isSorted`. For example, using `"a <= b"` instead of `"a < b"` is
incorrect and will cause failed assertions.
Params:
    less = Predicate the range should be sorted by.
    r = slice to check for sortedness.
Returns:
    `true` if the range is sorted, false otherwise. `isSorted` allows
    duplicates, $(LREF isStrictlyMonotonic) not.
*/
template isSorted(alias less = "a < b")
{
    import mir.functional: naryFun;
    static if (__traits(isSame, naryFun!less, less))
    ///
    @fastmath bool isSorted(SliceKind kind, size_t[] packs, Iterator)
        (Slice!(kind, packs, Iterator) slice)
        if (packs.length == 1)
    {
        if (slice.anyEmpty)
            return true;

        auto ahead = slice;
        ahead.popFront();

        static if (packs[0] == 1)
        {
            for (; !ahead.empty; ahead.popFront(), slice.popFront())
            {
                if (!less(ahead.front, slice.front)) continue;
                // Check for antisymmetric predicate
                assert(
                    !less(slice.front, ahead.front),
                    "Predicate for isSorted is not antisymmetric. Both" ~
                            " pred(a, b) and pred(b, a) are true for certain values.");
                return false;
            }
            return true;
        }
        else
        {
            static assert("isSorted does not implemented for multidimensional slices.");
        }
    }
    else
        alias isSorted = .isSorted!(naryFun!less);
}

/// ditto
template isStrictlyMonotonic(alias less = "a < b")
{
    import mir.functional: naryFun;
    static if (__traits(isSame, naryFun!less, less))
    ///
    @fastmath bool isStrictlyMonotonic(SliceKind kind, size_t[] packs, Iterator)
        (Slice!(kind, packs, Iterator) slice)
        if (packs.length == 1)
    {
        static if (__traits(isSame, less, less))
        ///
        import std.algorithm.searching : findAdjacent;
        import mir.functional: not;
        return findAdjacent!(not!less)(r).empty;
    }
    else
        alias isStrictlyMonotonic = .isStrictlyMonotonic!(naryFun!less);
}

///
template sort(alias less = "a < b")
{
    import mir.functional: naryFun;
    static if (__traits(isSame, naryFun!less, less))
    ///
    @fastmath Slice!(kind, packs, Iterator) sort(SliceKind kind, size_t[] packs, Iterator)
        (Slice!(kind, packs, Iterator) slice)
        if (packs.length == 1)
    {
        import mir.ndslice.topology: flattened;
        slice.flattened.quickSortImpl!less;
        return slice;
    }
    else
        alias sort = .sort!(naryFun!less);
}

void quickSortImpl(alias less, Iterator)(Slice!(SliceKind.continuous, [1], Iterator) slice)
{
    import mir.utility : swap;

    enum  max_depth = 64;
    enum naive_est = 1024 / slice.ElemType!0.sizeof;
    enum size_t naive = 32 > naive_est ? 32 : naive_est;
    //enum size_t naive = 1;
    static assert(naive >= 1);

    for(;;)
    {
        auto l = slice._iterator;
        auto r = l;
        r += slice.length;

        static if (naive > 1)
        {
            if (slice.length <= naive)
            {
                auto p = r;
                --p;
                while(p != l)
                {
                    --p;
                    static if (is(typeof(() nothrow
                        {
                            auto t = slice[0]; if (less(t, slice[0])) slice[0] = slice[0];
                        })))
                    {
                        auto d = p;
                        auto temp = *d;
                        auto c = d;
                        ++c;
                        if (less(*c, temp))
                        {
                            do
                            {
                                *d = *c;
                                ++d;
                                ++c;
                            }
                            while (c != r && less(*c, temp));
                            *d = temp;
                        }
                    }
                    else
                    {
                        auto d = p;
                        auto c = d;
                        ++c;
                        while (less(*c, *d))
                        {
                            swap(*d, *c);
                            d = c;
                            ++c;
                            if (c == maxJ) break;
                        }
                    }
                }
                return;
            }
        }
        else
        {
            if(slice.length <= 1)
                return;
        }

        // partition
        auto lessI = l;
        --r;
        auto pivotIdx = l + slice.length / 2;
        setPivot!less(slice.length, l, pivotIdx, r);
        auto pivot = *pivotIdx;
        --lessI;
        auto greaterI = r;
        swap(*pivotIdx, *greaterI);

        outer: for (;;)
        {
            do ++lessI;
            while (less(*lessI, pivot));
            assert(lessI <= greaterI, "sort: invalid comparison function.");
            for (;;)
            {
                if (greaterI == lessI)
                    break outer;
                --greaterI;
                if (!less(pivot, *greaterI))
                    break;
            }
            assert(lessI <= greaterI, "sort: invalid comparison function.");
            if (lessI == greaterI)
                break;
            swap(*lessI, *greaterI);
        }

        swap(*r, *lessI);

        ptrdiff_t len = lessI - l;
        auto tail = slice[len + 1 .. $];
        slice = slice[0 .. len];
        if (tail.length > slice.length)
            swap(slice, tail);
        quickSortImpl!less(tail);
    }
}

unittest
{
    import mir.ndslice.slice;

    int[10] arr = [7,1,3,2,9,0,5,4,8,6];

    auto data = arr[].ptr.sliced(arr.length);
    data.sort();
    assert(data.isSorted);
}

package void setPivot(alias less, Iterator)(size_t length, ref Iterator l, ref Iterator mid, ref Iterator r)
{
    if (length < 512)
    {
        if (length >= 32)
            medianOf!less(l, mid, r);
        return;
    }
    auto quarter = length >> 2;
    auto b = mid - quarter;
    auto e = mid + quarter;
    medianOf!less(l, e, mid, b, r);
}

package void medianOf(alias less, Iterator)
    (ref Iterator a, ref Iterator b, ref Iterator c)
{
    import mir.utility : swap;

    if (less(*c, *a)) // c < a
    {
        if (less(*a, *b)) // c < a < b
        {
            swap(*a, *b);
            swap(*a, *c);
        }
        else // c < a, b <= a
        {
            swap(*a, *c);
            if (less(*b, *a)) swap(*a, *b);
        }
    }
    else // a <= c
    {
        if (less(*b, *a)) // b < a <= c
        {
            swap(*a, *b);
        }
        else // a <= c, a <= b
        {
            if (less(*c, *b)) swap(*b, *c);
        }
    }
    assert(!less(*b, *a));
    assert(!less(*c, *b));
}

package void medianOf(alias less, Iterator)
    (ref Iterator a, ref Iterator b, ref Iterator c, ref Iterator d, ref Iterator e)
{
    import mir.utility : swap;
    // Credit: Teppo Niinimäki
    version(unittest) scope(success)
    {
        assert(!less(*c, *a));
        assert(!less(*c, *b));
        assert(!less(*d, *c));
        assert(!less(*e, *c));
    }

    if (less(*c, *a)) swap(*a, *c);
    if (less(*d, *b)) swap(*b, *d);
    if (less(*d, *c))
    {
        swap(*c, *d);
        swap(*a, *b);
    }
    if (less(*e, *b)) swap(*b, *e);
    if (less(*e, *c))
    {
        swap(*c, *e);
        if (less(*c, *a)) swap(*a, *c);
    }
    else
    {
        if (less(*c, *b)) swap(*b, *c);
    }
}
