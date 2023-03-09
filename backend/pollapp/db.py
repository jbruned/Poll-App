import hashlib

from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()


class NotFoundException(Exception):
    """
    Exception thrown when a resource is not found
    """
    pass


class AppSettings(db.Model):
    """
    Stores the PollApp application settings (currently only the admin password)
    There must only exist one object of this type (one row in the corresponding table)
    """
    __tablename__ = "settings"
    id = db.Column(db.Integer, primary_key=True)
    admin_password = db.Column(db.String(64), nullable=False)  # sha256 hash is 64 chars long (256 bytes)

    DEFAULT_ADMIN_PASSWORD = "admin"
    _PASSWORD_SALT = "80355aa66e1c958f9707fb9ac85a8a24"

    @staticmethod
    def get():
        """
        Returns the AppSettings object
        """
        return AppSettings.query.first()

    @staticmethod
    def is_initialized():
        """
        Returns True if the AppSettings object has been initialized
        """
        return AppSettings.query.count() > 0

    def set(self, admin_password: str):
        """
        Sets the admin password
        @param admin_password: The admin password
        """
        self.admin_password = AppSettings.get_hashed_password(admin_password)
        db.session.commit()

    @staticmethod
    def init(admin_password: str = DEFAULT_ADMIN_PASSWORD):
        """
        Initializes the AppSettings object
        @param admin_password: The admin password
        """
        if AppSettings.is_initialized():
            AppSettings.clear()
        settings = AppSettings(admin_password=AppSettings.get_hashed_password(admin_password))
        db.session.add(settings)
        db.session.commit()

    @staticmethod
    def get_hashed_password(password: str) -> str:
        """
        Returns the hash for the input password, using SHA-256 and a fixed salt
        @param password: original password
        @return: hashed password
        """
        return hashlib.sha256((password + AppSettings._PASSWORD_SALT).encode()).hexdigest()

    @staticmethod
    def clear():
        """
        Clears the AppSettings object
        """
        AppSettings.query.delete()
        db.session.commit()

    def is_password_correct(self, password: str) -> bool:
        """
        Checks the provided password against the hash
        @param password: input password
        @return: True if the password is correct, False otherwise
        """
        return self.get_hashed_password(password) == self.admin_password


class Poll(db.Model):
    """
    Stores a ProtectedService's settings
    """
    __tablename__ = "polls"
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(64), nullable=False)
    author = db.Column(db.String(64), nullable=True)
    timestamp = db.Column(db.DateTime, nullable=False)

    # options = db.relationship('Option', backref='poll', lazy=True, cascade="all, delete-orphan")

    @staticmethod
    def get(poll_id: int = None):
        """
        Returns the poll with the given ID, or all the polls if no ID is given
        :param poll_id: The poll ID
        :return: The poll with the given ID, or all the polls if no ID is given
        """
        if poll_id is None:
            return Poll.query.all()
        item = Poll.query.get(poll_id)
        if item is None:
            raise NotFoundException()
        return item

    @staticmethod
    def insert(title: str, author: str):
        """
        Adds a new poll
        @param title: The poll title
        @param author: The poll author
        """
        poll = Poll(title=title, author=author, timestamp=db.func.now())
        db.session.add(poll)
        db.session.commit()
        return poll

    def delete(self):
        """
        Deletes the poll
        """
        db.session.delete(self)
        db.session.commit()

    def update(self, title: str):
        """
        Updates the poll data
        @param title: The poll title
        """
        self.title = title
        db.session.commit()

    def get_options(self):
        """
        Returns the options for the poll
        """
        return Option.query.filter_by(poll_id=self.id).all()

    def get_answers_count(self):
        """
        Returns the number of answers for the poll
        """
        return Answer.query.filter_by(poll_id=self.id).count()

    def get_answers_count_by_option(self):
        """
        Returns the number of answers for each option of the poll
        """
        return Answer.query.filter_by(poll_id=self.id).group_by(Answer.option_id).count()

    def has_answered(self, session_id: str):
        """
        Returns True if the poll has been answered by the user with the given session ID
        @param session_id: The user session ID
        """
        return db.session.query(Answer).join(Option) \
            .filter(Option.poll_id == self.id, Answer.session_id == session_id).count() > 0

    def get_answer(self, session_id: str):
        """
        Returns the answer of the user with the given session ID
        @param session_id: The user session ID
        """
        return db.session.query(Answer).join(Option) \
            .filter(Option.poll_id == self.id, Answer.session_id == session_id).first()

    def get_answered_option(self, session_id: str):
        """
        Returns the answer option of the user with the given session ID
        @param session_id: The user session ID
        @return: The answer option of the user with the given session ID if the user has already voted, None otherwise
        """
        answer = self.get_answer(session_id)
        if answer is None:
            return None
        item = Option.query.get(answer.option_id)
        if item is None:
            raise NotFoundException()
        return item

    @staticmethod
    def get_polls():
        """
        Returns a list with all the polls including:
            - the id
            - the title
            - the author
            - the timestamp
            - the option count
            - the answer count
        """
        return db.session.query(Poll, db.func.count(Option.id).label('options_count'),
                                db.func.count(Answer.id).label('answers_count')) \
            .outerjoin(Option, Poll.id == Option.poll_id) \
            .outerjoin(Answer, Option.id == Answer.option_id) \
            .group_by(Poll.id).all()
        # return db.session.query(Poll, db.func.count(Answer.id).label('answers_count')) \
        #     .outerjoin(Option, Poll.id == Option.poll_id) \
        #     .outerjoin(Answer, Option.id == Answer.option_id) \
        #     .group_by(Poll.id).all()

    def get_info(self, session_id = None):
        """
        Returns a dictionary with the poll info
        """
        return {
            'id': self.id,
            'title': self.title,
            'author': self.author,
            'timestamp': self.timestamp,
            'options': [option.get_info() for option in self.get_options()],
            'answers_count': self.get_answers_count(),
            'answers_count_by_option': self.get_answers_count_by_option(),
            'user_answered': self.get_answered_option(session_id) if session_id is not None else False
        }


class Option(db.Model):
    """
    Stores a login attempt from an IP and a ProtectedService
    """
    __tablename__ = "options"
    id = db.Column(db.Integer, primary_key=True)
    poll_id = db.Column(db.Integer, db.ForeignKey('polls.id', ondelete='CASCADE'), nullable=False)
    text = db.Column(db.String(64), nullable=False)

    # answers = db.relationship('Answer', backref='option', lazy=True, cascade="all, delete-orphan")

    @staticmethod
    def get(option_id: int):
        """
        Returns the option with the given ID
        :param option_id: The option ID
        :return: The option with the given ID
        """
        item = Option.query.get(option_id)
        if item is None:
            raise NotFoundException()
        return item

    @staticmethod
    def insert(poll_id: int, text: str):
        """
        Adds a new option for the poll with the given ID
        @param poll_id: The poll ID
        @param text: The option text
        """
        option = Option(poll_id=poll_id, title=text)
        db.session.add(option)
        db.session.commit()
        return option

    def delete(self):
        """
        Deletes the option
        """
        db.session.delete(self)
        db.session.commit()

    def update(self, text: str):
        """
        Updates the option data
        @param text: The option text
        """
        self.text = text
        db.session.commit()

    def get_poll(self):
        """
        Returns the poll for the option
        """
        return Poll.get(self.poll_id)

    def vote(self, session_id: str):
        """
        Adds a new answer for the option
        @param session_id: The user session ID
        @return: The answer object if the user has not already voted, None otherwise
        """
        if self.get_poll().has_answered(session_id):
            return None
        answer = Answer(option_id=self.id, session_id=session_id, timestamp=db.func.now())
        db.session.add(answer)
        db.session.commit()
        return answer


class Answer(db.Model):
    """
    Stores an answer for a poll
    """
    __tablename__ = "answers"
    id = db.Column(db.Integer, primary_key=True)
    option_id = db.Column(db.Integer, db.ForeignKey('options.id', ondelete='CASCADE'), nullable=False)
    session_id = db.Column(db.String(64), nullable=False)
    timestamp = db.Column(db.DateTime, nullable=False)

    def delete(self):
        """
        Deletes the answer
        """
        db.session.delete(self)
        db.session.commit()