class BoardObserver < ActiveRecord::Observer

    def after_create(board)
        Mailer.deliver_board_added(board) if Setting.notified_events.include?('board_added')
    end

end
